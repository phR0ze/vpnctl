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
  mattr_accessor(:reposition)   # array for tracking repositioning of window
  mattr_accessor(:positioned)   # flag to indicate if initial position has been set

  # Load paths and styles
  # @param uifile [String] file to load
  # @param datapath [String] to load styles from
  # @param icon [String] relative path
  # @param image [String] relative path
  # @param position [Array(x,y)] for window
  def init(uifile, datapath, icon, image, position)
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

    # Set default/saved position for window
    # Turns out that Gtk+ doesn't know what the size of a window is until it has
    # been realized (i.e. painted on the screen) so we have to setup a signal to
    # manually do this for Gtk once the allocation values have been set
    self.main.signal_connect('size-allocate'){
      if !self.positioned
        self.reposition_on_parent(position)
        self.positioned = true
      end
    }
  end

  # Apply css for the widget and all children recursively
  # @param widget [Gtk::Widget] to apply styles to
  def apply_styles(*widget)
    widget = widget.first || Gas.main

    widget.style_context.add_provider(self.css, Gtk::StyleProvider::PRIORITY_USER)
    return unless widget.respond_to?(:children)
    widget.children.each{|x| apply_styles(x)}
  end

  # Reposition the window in its parent
  # @param win [GtkWindow] to reposition on its parent
  # @param position [Array(x, y)] to set for child relative to parent
  def reposition_on_parent(*args)
    win = args.find{|x| !x.is_a?(Array)}
    position = args.find{|x| x.is_a?(Array)}
    win = Gas.main if !win

    # Get parent dimensions and position
    if win == Gas.main
      parent_x, parent_y = 0
      parent_w = win.screen.width
      parent_h = win.screen.height
    else
      parent = win.parent || Gas.main
      parent_w, parent_h = parent.size
      parent_x, parent_y = parent.position
    end

    # Default to center if no position is given
    child_w, child_h = win.size
    if position
      new_x = parent_x + position.first
      new_y = parent_y + position.last
    else
      new_x = parent_w/2 - child_w/2
      new_y = parent_h/2 - child_h/2
    end

    win.move(new_x, new_y)
  end

  # Setup window to be able to be repositioned
  # by clicking on non-child widget area to move with dragging
  # @param win [GtkWindow] to enable repositioning for
  def enable_repositioning(win)
    self.reposition ||= {}
    id = win.object_id

    win.signal_connect('button_press_event'){|w,e|
      if e.button == 1                          # Start on repositioning on left mouse click
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

  # Dialog wrapper for getting info from user
  class Prompt

    # Create a new dialog
    # @param title [String] title of the prompt dialog
    # @param parent [Gtk::Widget] parent widget
    def initialize(title, parent:nil)
      @title = title
      @parent = parent || Gas.main

      @entry = nil
      @positioned = false
      @diag = Gtk::Dialog.new(parent:@parent, flags:[:modal, :destroy_with_parent],
        buttons:[["_OK", :ok], ["_Cancel", :cancel]])
      @diag.set_default_response(Gtk::ResponseType::CANCEL)

      self.add_content
      self.apply_styles
      self.connect_signals
    end

    # Returns the entered string
    def run
      res = nil

      @diag.show_all
      if @diag.run == Gtk::ResponseType::OK
        res = @entry.text
      end
      @diag.destroy

      return res
    end

    def add_content
      hbox = Gtk::Box.new(:horizontal, 2)
      title = Gtk::Label.new(@title)
      title.style_context.add_class('subtitle-label')
      image = Gtk::Image.new(pixbuf: Gas.image)

      @entry = Gtk::Entry.new
      @entry.visibility = false

      hbox.pack_start(image, expand: false, fill: false, padding: 0)
      hbox.pack_start(title, expand: false, fill: false, padding: 0)
      @diag.content_area.pack_start(hbox)
      @diag.content_area.pack_start(@entry)
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
end
