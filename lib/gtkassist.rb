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

module GtkAssist
  extend self
  mattr_accessor(:css) 

  # Load styles from the given path
  # @param path [String] path to styles to load
  def load_styles(path)
    self.css = Gtk::CssProvider.new
    self.css.load(path: path)
  end

  # Apply css for the widget and all children recursively
  # @param widget [Gtk::Widget] widget to apply styles to
  def apply_styles(widget)
    widget.style_context.add_provider(self.css, Gtk::StyleProvider::PRIORITY_USER)
    return unless widget.respond_to?(:children)
    widget.children.each{|x| apply_styles(x)}
  end
end

class GetPass < Gtk::Dialog

  # Create a new dialog
  # @param parent [Gtk::Widget] parent widget
  def initialize(parent)
    @parent = parent

    super(parent:parent, flags:[:modal, :destroy_with_parent],
      buttons:[["_OK", :ok], ["_Cancel", :cancel]])

    self.add_content
    self.apply_styles
    self.run
  end

  def run
    self.show
  end

  def add_content
    vbox = Gtk::Box.new(:vertical, 3)
    #image = Gtk::Image.new(icon_name: "dialog-question", size: :dialog)
    #vbox.pack_start(image, expand: false, fill: false, padding: 0)

    self.content_area.pack_start(vbox)
  end

  def apply_styles
    # Turn off decorations
    self.decorated = false

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
    set_classes.call(self)

    # Apply styles from css
    GtkAssist.apply_styles(self)
  end

  def connect_signals
    self.signal_connect('key_press_event'){|w,e|
      if e.keyval == Gdk::Keyval::KEY_Return
        self.signal_emit(:response, Gtk::ResponseType::OK)
      end
    }
  end
end
