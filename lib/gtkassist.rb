#MIT License
#Copyright (c) 2018 phR0ze
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

require 'nub'
require 'gtk3'

# Short hand namespace name for GtkAssist
module Gas
  extend self
  mattr_accessor(:datapath)
  mattr_accessor(:uipath)
  mattr_accessor(:imagepath)

  mattr_accessor(:builder)
  mattr_accessor(:main)
  mattr_accessor(:css)
  mattr_accessor(:image)

  # Mouse pointers
  mattr_accessor(:cursor_waiting)
  mattr_accessor(:cursor_grabbing)

  # Window positioning
  mattr_accessor(:reposition)

  # Load paths and styles
  # @param uifile [String] ui file to load
  # @param datapath [String] path to styles to load
  # @param icon [String] image relative path to icon
  # @param image [String] image relative path to larger image
  def init(uifile, datapath, icon, image)
    self.datapath = datapath
    self.uipath = File.join(datapath, "ui")
    self.imagepath = File.join(datapath, "images")

    # Load builder and main
    self.builder = Gtk::Builder.new
    self.builder.add_from_file(File.join(self.uipath, uifile))
    self.main = self.builder.get_object("main")

    # Setup mouse pointers
    self.cursor_waiting = Gdk::Cursor.new("wait")
    self.cursor_grabbing = Gdk::Cursor.new("grabbing")

    # Load styles
    self.css = Gtk::CssProvider.new
    self.css.load(path: File.join(self.uipath, "styles.css"))

    # Load images
    self.image = GdkPixbuf::Pixbuf.new(file:File.join(self.imagepath, image))

    # Configure main
    self.main.icon = GdkPixbuf::Pixbuf.new(file:File.join(self.imagepath, icon))
    self.enable_repositioning(self.main)

    # Exit on Alt-F4 or Escape
    self.main.signal_connect('destroy'){ Gtk.main_quit }
    self.main.signal_connect('key_press_event'){|w,e|
      Gtk.main_quit if e.keyval == Gdk::Keyval::KEY_Escape
    }
  end

  # Apply css for the widget and all children recursively
  # @param widget [Gtk::Widget] widget to apply styles to
  def apply_styles(widget)
    widget.style_context.add_provider(self.css, Gtk::StyleProvider::PRIORITY_USER)
    return unless widget.respond_to?(:children)
    widget.children.each{|x| apply_styles(x)}
  end

  def reposition_on_parent
    #x, y = @main.position
    #@pass_diag.move(x, y)
    #pass = @pass_entry.text if @pass_diag.run == Gtk::ResponseType::OK
    #@pass_entry.text = ""
    #@pass_diag.hide
  end

  # Setup window to be able to be repositioned
  # by clicking on non-child widget area to move with dragging
  # @param win [GtkWindow] window to enable repositioning for
  def enable_repositioning(win)
    self.reposition ||= {}
    id = win.object_id

    win.signal_connect('button_press_event'){|w,e|
      if e.button == 0                          # Start on repositioning on left mouse click
        self.reposition[id] = [e.x, e.y]            # Add window to repositioning hash for tracking
        win.window.set_cursor(self.cursor_grabbing) # Set cursor to grabbing for movement indication
        win.grab_add                            # Ignore all other widget input during movement
      end
    }
    win.signal_connect('button_release_event'){
      self.reposition.delete(id)                    # Remove from currently repositioning tracking
      win.window.set_cursor(nil)                # Reset cursor back to 'default'
      win.grab_remove                           # Remove block on other widget inputs
    }
    win.signal_connect('motion_notify_event'){|w,e|
      if self.reposition.key?(id)
        # Motion event coordinants are in reference to the widget and go negative when leaving
        # window borders. Thus movement of window position can be calculated by the postion of the
        # window + the difference of x0 and x2. Since 0,0 is top left we do it backwards  e.g.
        # x + (x1 - x1) = new position
        _win, motion_x, motion_y, state = w.window.get_device_position(e.device)
        old_x, old_y = w.position
        new_x = old_x + (motion_x - self.reposition[id].first)
        new_y = old_y + (motion_y - self.reposition[id].last)
        win.move(new_x, new_y)
      end
    }
  end
end

class Prompt

  # Create a new dialog
  # @param title [String] title of the prompt dialog
  # @param parent [Gtk::Widget] parent widget
  def initialize(title, parent:nil)
    @parent = parent || Gas.main
    @title = title

    @diag = Gtk::Dialog.new(parent:@parent, flags:[:modal, :destroy_with_parent],
      buttons:[["_OK", :ok], ["_Cancel", :cancel]])

    self.add_content
    self.apply_styles
  end

  # Returns the entered string
  def run
    res = nil
    res = "ok" if @diag.run == Gtk::ResponseType::OK
    @diag.destroy
    return res
  end

  def add_content
    vbox = Gtk::Box.new(:vertical, 3)
    title = Gtk::Label.new(@title)
    image = Gtk::Image.new(pixbuf: Gas.image)

    vbox.pack_start(image, expand: false, fill: false, padding: 0)
    vbox.pack_start(title, expand: false, fill: false, padding: 0)
    @diag.content_area.pack_start(vbox)
  end

  def apply_styles
    # Turn off decorations
    @diag.decorated = false

    # Add appropriate css classes to dialog buttons
    set_classes = -> (x) {
      if x.is_a?(Gtk::Button)
        ctx = x.style_context
        ctx.add_class('button-ok') if x.label == "_OK"
        ctx.add_class('button-cancel') if x.label == "_Cancel"
      end
      return unless x.respond_to?(:children)
      x.children.each{|y| set_classes.call(y)}
    }
    set_classes.call(@diag)

    # Apply styles from css
    Gas.apply_styles(@diag)
  end

  def connect_signals
    @diag.signal_connect('key_press_event'){|w,e|
      if e.keyval == Gdk::Keyval::KEY_Return
        @diag.signal_emit(:response, Gtk::ResponseType::OK)
      end
    }
  end
end
