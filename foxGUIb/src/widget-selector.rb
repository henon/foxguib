# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)
require "singleton"
require 'widget-lists'
#require 'container'
class WidgetSelector
  include Singleton
	def initialize
		#~ create_dlg
		#~ add $popular_widgets, @popular, @pop_cols, @pop_cnt
		#~ add $container_widgets, @container, @cont_cols, @cont_cnt
		#~ add $all_widgets, @all, @all_cols, @all_cnt
		@dlg=MAINWIN.wdg_Frame
		@dlg.vSpacing=2
		create_popup @dlg
		generate( $input_display_widgets, "Input and Display").open_body
		generate( $container_widgets, "Container and Layoutmanager").open_body
		generate $menu_widgets, "Menubar and Menu"
		generate $bar_widgets, "Bars"
		generate $tab_widgets, "Switchers"
		generate $all_widgets, "Others"
	end
	def make_container(p, title)
		c=Container.new(p)
		c.title=title
		c.header.backColor=HEADER_COLOR
		m=FXMatrix.new c, 3, MATRIX_BY_COLUMNS
		m.pad 1,1,1,1
		m.hSpacing=1
		m.vSpacing=1
		m.backColor=FXRGB(255,255,255)
		return c, m
	end
	def generate list, title
		c, m=make_container(@dlg, title)
		list.each{|classname| 
			b=Button.new m
			b.backColor=FXRGB(255,255,255)
			b.justify=JUSTIFY_LEFT
			b.iconPosition=ICON_BEFORE_TEXT
			b.buttonStyle=BUTTON_TOOLBAR
			iconfile="src/gui/#{classname}.tga"
			#puts "#{iconfile} does not exist." if $DEBUG and !File.exist?( iconfile)
			b.icon=Icon.new(iconfile).img  
			b.text=classname.to_s 
			b.layoutHints=LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH
			b.height=40
			b.width=120
			b.connect(SEL_COMMAND){ DocMan.instance.add_widget classname.to_s }
			b.connect(SEL_RIGHTBUTTONPRESS){ |s,x,e|
				@classname=classname.to_s
				@classname_caption.text="[#{@classname}]"
				@popup.popup nil, e.root_x, e.root_y
			}
		}
		c.close_body
		c
	end
	def create_popup(p)
		@popup=Popup.new(p) {|po| 
			@classname_caption=MenuCaption.new(po){|c|
				c.text='...'
			}
			MenuSeparator.new(po)
			MenuCommand.new(po){|c|
				c.text="add before"
				c.connect(SEL_COMMAND){ DocMan.instance.add_widget @classname, "before" }
			}
			MenuCommand.new(po){|c|
				c.text="add after"
				c.connect(SEL_COMMAND){ DocMan.instance.add_widget @classname }
			}
			MenuCommand.new(po){|c|
				c.text="add inside"
				c.connect(SEL_COMMAND){ DocMan.instance.add_widget @classname, "inside" }
			}
			MenuSeparator.new(po)
			MenuCommand.new(po){|c|
				c.text="cancel"
			}
		}
	end
end