# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

# Description: an adapter that simplifies the fox api
# reading this file gives you the information what widgets are currently implemented

#~ if __FILE__==$0
	#~ require "fox14"
#~ end

require 'middle-right-mouse'
require "fxobjects"
require "radio_group"

# workaround for a fxruby 1.4.4 bug
if Fox.fxrubyversion=="1.4.4"
	class Fox::FXMenuCaption
		def text= text
			@text=text
			self.setText(text)
		end
		
		def text
			return @text
		end
	end
end

module FX
# mixin module definitions
module CheckState
	def state=(x)
		setCheck(x ? Fox::TRUE : Fox::FALSE)
	end
	def state
		return( getCheckState==Fox::TRUE ? true : false)
	end
end
module RangeAccessor
	def range= val
		val = val.last..val.first if val.last < val.first
		setRange val
	end
	def range
		getRange
	end
end
module RadioMutexInterface
	def init_radio_mutex
		@radioGroup=RadioGroup.new
		@radioGroup.on_event_selected{|r| event_selected(r) }
	end
	
	def add_radio_option widget
		@radioGroup << widget
	end
	
	def selected_radio
		return @radioGroup.selected
	end
end

# class definitions
class ArrowButton < Fox::FXArrowButton
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::ARROW_NORMAL
	end
end
class Button < Fox::FXButton
	include Responder
	include RightBtn
	include MiddleBtn
	def initialize(p, opts=0)
		super(p, 'Button', nil, nil, 0, Fox::BUTTON_NORMAL|opts)
		handleMMB_Events
		handleRMB_Events
	end
	def state=(x)
		if x==true
			setState(Fox::STATE_DOWN)
		elsif x==false
			setState(Fox::STATE_UP)
		elsif x.class==Fixnum
			setState(x)
		end
	end
	def state
		if getState==Fox::STATE_DOWN then return true 
		elsif getState==Fox::STATE_CHECKED then return true 
		end
		return false
	end
	alias :buttonButtonStyle= :buttonStyle=
	alias :buttonButtonStyle :buttonStyle
end
#~ class Calendar < Fox::FXCalendar
	#~ def initialize(p, opts=0)
		#~ super p, initial_date=Time.now, tgt=nil, sel=0, opts
		
	#~ end
#~ end
class Canvas < Fox::FXCanvas
	def initialize(p, opts=0); super p; 
	end
end
class CheckButton < Fox::FXCheckButton
	def initialize(p, opts=0)
		super(p, 'CheckButton')
	end
	include CheckState
end
class ComboBox < Fox::FXComboBox
	def initialize(p, opts=0)
		super(p , 10, nil, 0, opts|Fox::FRAME_SUNKEN)
	end
	
	def comboItems= string
		c=currentItem
		clearItems
		array=string.split(/\r?\n/)
		array.each{|s|
			appendItem s
		}
		self.numVisible=array.size
    begin
      self.currentItem=c
    rescue Exception
    end
	end
	def comboItems
		array = []
		self.each{|text, d|
			array<< text
		}
		return array.join( "\n")
	end
	def auto_resize
		size=0
		self.each{|text, d|
			size=text.size if size < text.size
		}
		self.numColumns=size
		self.numVisible=self.numItems
	end	
end
class Dial < Fox::FXDial
	def initialize(p, opts=0)
		super(p, nil, 0, opts|Fox::DIAL_NORMAL)		
	end
end
class DialogBox < Fox::FXDialogBox
	def initialize(p, opts=0)
		#@eventListeners=[]
		super(p, 'title', Fox::DECOR_ALL)
		pad(0,0,0,0)
		handleMMB_Events
	end
	#attr_accessor :eventListeners
	include Responder
	include MiddleBtn
	#~ def show(*args)
		#~ #dbg
		#~ @eventListeners.each{|el| el.on_event "DialogBox.show", self }
		#~ create if $fxapp.created? and not created?
		#~ super
	#~ end
	
	#~ def hide(*args)
		#~ #dbg
		#~ @eventListeners.each{|el| el.on_event "DialogBox.hide", self }
		#~ super
	#~ end
	
	#~ def destroy(*args)
		#~ #dbg
		#~ @eventListeners.each{|el| el.on_event "DialogBox.destroy", self }
		#~ super
	#~ end
end
class DirBox  < Fox::FXDirBox 
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::FRAME_SUNKEN|Fox::TREELISTBOX_NORMAL
	end
end
class DirList  < Fox::FXDirList
	def initialize(p, opts=0)
		super p, nil, 0, opts
	end
end
class DriveBox  < Fox::FXDriveBox
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::FRAME_SUNKEN|Fox::LISTBOX_NORMAL
	end
end
class FileList  < Fox::FXFileList
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class Header  < Fox::FXHeader
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y|Fox::HEADER_NORMAL
	end
end
class GroupBox < Fox::FXGroupBox
	def initialize(p, opts=0)
		super(p, 'GroupBox', opts|Fox::FRAME_GROOVE, 0,0,0,0,4,4,4,4,4,4)
	end
end
class HorizontalFrame < Fox::FXHorizontalFrame
	def initialize(p, opts=0)
		super(p, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y, 0,0,0,0,0,0,0,0,0,0)
	end
end
class HorizontalSeparator < Fox::FXHorizontalSeparator
	def initialize(p, opts=Fox::SEPARATOR_GROOVE)
		super p, Fox::LAYOUT_FILL_X|opts
	end
end
class IconList  < Fox::FXIconList
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y|Fox::HEADER_NORMAL
	end
	alias :iconListStyle= :listStyle=
	alias :iconListStyle :listStyle
	
	def addItems names, imagefiles
		names.size.times do |i|
			img = loadImage(imagefiles[i] )			
			appendItem( names[i], nil, img)		
		end
	end
end
class Label < Fox::FXLabel
	def initialize(p, opts=0)
		super p, 'Label'
	end
end
class List  < Fox::FXList
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y|Fox::LIST_NORMAL
	end
	alias :listListStyle= :listStyle=
	alias :listListStyle :listStyle
end
class ListBox  < Fox::FXListBox
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::FRAME_SUNKEN|Fox::LISTBOX_NORMAL
	end
end
class MainWindow < Fox::FXMainWindow
	#accepts app or any widget as parent
	def initialize(p, opts=0)
		p=p.app if p.kind_of? Fox::FXId
		super p, "MainWindow", nil, nil, Fox::DECOR_ALL
	end
end
class Matrix < Fox::FXMatrix
	def initialize(p, opts=0)
		super p, 1, opts|Fox::MATRIX_BY_ROWS|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
		@cols=self.numColumns=1
		@rows=self.numRows=1
	end
	#update the dimension when switching matrix by rows/columns
	def matrixStyle=code
		super code
		numColumns=@cols
		numRows=@rows
	end
	def numColumns=(int)
		super @cols=dim_check( int)
	end
	def numRows=(int)
		super @rows=dim_check( int)
	end
	def dim_check int
		#dimension must be a Numeric > 0
		return 1 if int < 1 
		return 1 unless int.kind_of?( Numeric)
		return int
	end
end
class MDIClient < Fox::FXMDIClient
	def initialize(p, opts=0)
		super p, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class MenuButton  < Fox::FXMenuButton
	include Responder
	include MiddleBtn
	def initialize(p, opts=0)
		super p, 'MenuButton', nil, nil, opts|Fox::JUSTIFY_NORMAL|Fox::ICON_BEFORE_TEXT|Fox::MENUBUTTON_DOWN
		handleMMB_Events
	end
	alias :menuButtonStyle= :buttonStyle=
	alias :menuButtonStyle :buttonStyle
end
class MenuCaption < Fox::FXMenuCaption
	include Responder
	include MiddleBtn
	def initialize(p, opts=0)
		@text=text if Fox.fxrubyversion=="1.4.4"
		super p, 'MenuCaption'
		handleMMB_Events
	end
end
class MenuCascade < Fox::FXMenuCascade
	include Responder
	include MiddleBtn
	def initialize(p, text='MenuCascade')
		@text=text if Fox.fxrubyversion=="1.4.4"
		super p, text
		handleMMB_Events
	end
end
class MenuCheck < Fox::FXMenuCheck
	include Responder
	include MiddleBtn
	include CheckState
	def initialize(p, text="MenuCheck")
		@text=text if Fox.fxrubyversion=="1.4.4"
		super(p, text)
	end
end
class MenuCommand < Fox::FXMenuCommand
	include Responder
	include MiddleBtn
	def initialize(p, text='MenuCommand')
		@text=text if Fox.fxrubyversion=="1.4.4"
		super p, text
		handleMMB_Events
	end
end
class MenuPane < Fox::FXMenuPane
	include Responder
	include MiddleBtn
	include RadioMutexInterface
	def initialize(p, opts=0)
		init_radio_mutex
		super p
		p.menu=self
		handleMMB_Events
	end
end
class MenuRadio < Fox::FXMenuRadio
	include Responder
	include MiddleBtn
	include CheckState
	def initialize(p, text="MenuRadio")
		@text=text if Fox.fxrubyversion=="1.4.4"
		super(p, text)
		self.parent.add_radio_option self if self.parent.respond_to? :add_radio_option
	end
end
class MenuTitle < Fox::FXMenuTitle
	include Responder
	include MiddleBtn
	def initialize(p, text='MenuTitle')
		@text=text if Fox.fxrubyversion=="1.4.4"
		super p, text
		handleMMB_Events
	end
end
class MenuBar < Fox::FXMenuBar
	def initialize(p, opts=0)
		super p, opts|Fox::LAYOUT_FILL_X
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
end
class MenuSeparator < Fox::FXMenuSeparator
	def initialize(p, opts=0)
		super p, opts
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
end
class Option < Fox::FXOption
	def initialize(p, opts=0)
		super p, 'Option', nil, nil, 0, opts|Fox::JUSTIFY_NORMAL|Fox::ICON_BEFORE_TEXT
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
end
class OptionMenu < Fox::FXOptionMenu
	def initialize(p, opts=0)
		super p, nil, opts|Fox::JUSTIFY_NORMAL|Fox::ICON_BEFORE_TEXT
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
	#alias :menu= :popup=
	#alias :menu :popup 
end
class Packer < Fox::FXPacker
	def initialize(p, opts=0)
		super(p, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y,0,0,0,0,4,4,0,0,0,0)
	end
end
class Popup < Fox::FXPopup
	def initialize(p, opts=0)
		init_radio_mutex
		super p, opts|Fox::POPUP_VERTICAL|Fox::FRAME_RAISED|Fox::FRAME_THICK
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
	include RadioMutexInterface	
end
class ProgressBar < Fox::FXProgressBar
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X
		self.displayText=Fox::TRUE
	end
	def displayText=bool
		@displaysText=bool
		bool ? showNumber : hideNumber
	end
	def displayText
		@displaysText=Fox::FALSE if @displaysText.nil?
		@displaysText
	end
end
class RadioButton < Fox::FXRadioButton
	def initialize(p, opts=0)
		super(p,'RadioButton', nil, 0, opts|Fox::ICON_BEFORE_TEXT)
		self.parent.add_radio_option self if self.parent.respond_to? :add_radio_option
	end
	include CheckState
end
class ScrollArea < Fox::FXScrollArea
	def initialize(p, opts=0)
		super(p)
		self.layoutHints=Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class ScrollBar < Fox::FXScrollBar
	def initialize(p, opts=0)
		super p
	end
	alias :contentSize :range
	alias :contentSize= :range=
end
class ScrollWindow < Fox::FXScrollWindow
	def initialize(p, opts=0)
		super p 
		self.layoutHints=Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class Shutter < Fox::FXShutter
	def initialize(p, opts=0)
		super p,nil,0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y|Fox::LAYOUT_TOP|Fox::LAYOUT_LEFT|Fox::FRAME_SUNKEN,0,0,0,0,0,0,0,0,0,0
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
end
class ShutterItem < Fox::FXShutterItem
	def initialize(p, opts=0)
		super p, 'ShutterItem', nil, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_TOP|Fox::LAYOUT_LEFT, 0, 0, 0, 0, 2, 2, 4, 4, 4, 4
		#~ button.frameStyle=Fox::FRAME_NONE
		#~ content.frameStyle=Fox::FRAME_NONE
		button.padBottom = 3
		button.padTop = 3
		button.padLeft = 5
		button.padRight = 5
		handleMMB_Events
	end
	def text=(text)
		button.text=text
	end
	def text
		button.text
	end
	include Responder
	include MiddleBtn
end
class Slider < Fox::FXSlider
	def initialize(p, opts=0)
		super p,nil,0, opts|Fox::SLIDER_NORMAL|Fox::LAYOUT_FILL_X
	end
	include RangeAccessor
end
class Spinner < Fox::FXSpinner
	def initialize(p, opts=0)
		super p,3,nil,0, opts|Fox::FRAME_SUNKEN
	end
	include RangeAccessor
end
class Splitter < Fox::FXSplitter
	def initialize(p, opts=0)
		super(p)
		self.layoutHints=Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class Switcher < Fox::FXSwitcher
	def initialize(p, opts=0)
		super(p, opts)
	end
	def current=(*args)
		begin
			super
		rescue Exception
		end
	end
end
class StatusBar < Fox::FXStatusBar
	def initialize(p, opts=0)
		super p, opts|Fox::LAYOUT_FILL_X
	end
end
class StatusLine < Fox::FXStatusLine
	def initialize(p, opts=0)
		super p
	end
end
module TabBarInterface
	attr_reader :tabs
	def create_tab( text="TabItem")
		@tabs||=[]
		return TabItem.new(self){|i|
			@tabs << i
			i.text=text
		}
	end
	def remove_tab tab
		@tabs.delete tab
		self.removeChild( tab)
	end
end
class TabBar < Fox::FXTabBar
	include TabBarInterface
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X
	end
end
class TabBook < Fox::FXTabBook
	include TabBarInterface
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
end
class TabItem < Fox::FXTabItem
	def initialize(p, opts=0)
		super p, 'TabItem'
	end
	def index
		return self.parent.tabs.index( self)
	end
end
class Text < Fox::FXText
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
		text = 'Text'
	end
	alias :textTextStyle= :textStyle=
	alias :textTextStyle :textStyle
end
class TextField < Fox::FXTextField
	def initialize(p, opts=0)
		super p, 10, nil, 0, opts|Fox::FRAME_SUNKEN
		text = 'TextField'
	end
		
	def text=(*args)
		args.collect!{ |a| a.to_s }
		super *args
	end
	
	alias :textFieldTextStyle= :textStyle=
	alias :textFieldTextStyle :textStyle
end
class ToggleButton < Fox::FXToggleButton
	def initialize p, opts=0
		super p, 'Toggle', 'Button', nil,nil,nil,0, opts|Fox::TOGGLEBUTTON_KEEPSTATE
	end
	def altImg= filename
		if filename.size>0
			setAltIcon loadImage( filename)
			@alt_icon_filename=filename
		end
	end
	def altImg
		@alt_icon_filename.to_s
	end
end
class ToolBar < Fox::FXToolBar
	def initialize(p, opts=0)
		super p, opts|Fox::LAYOUT_FILL_X
	end
end
class TreeList < Fox::FXTreeList
	def initialize(p, opts=0)
		super p, nil, 0, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
	end
	alias :treeListStyle= :listStyle=
	alias :treeListStyle :listStyle
	
	def initialize_language_ids
		self.each{|ti|
			ti.initialize_language_ids			
		}
	end
end
class VerticalFrame < Fox::FXVerticalFrame
	def initialize(p, opts=0)
		super(p, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y, 0,0,0,0,0,0,0,0,0,0)
	end
end
class VerticalSeparator < Fox::FXVerticalSeparator
	def initialize(p, opts=Fox::SEPARATOR_GROOVE)
		super p, Fox::LAYOUT_FILL_Y|opts
	end
end
class WidgetTable < GroupBox
	def initialize(p, opts=0)
		@c={}
		@r=[]
		@nc=0;
		super
		self.text=""
		self.vSpacing=0
		self.frameStyle=FRAME_NONE
		#~ self.layoutHints=Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
		self.pad 2,2,2,2
	end
	def rows; @r.size; end
	def cols; @nc; end
	def size=(w, h)
		#TODO implement
	end
	def add_col
		@nc+=1
		@r.each_with_index{|r, y|
			VerticalFrame.new(r){|f| @c[[@nc-1,y]]=f 
				f.pad 0,0,0,0
			}
		}
	end
	def add_row
		HorizontalFrame.new( self) {|h|
			h.frameStyle=FRAME_NONE
			h.pad 0,0,0,0
			h.layoutHints=Fox::LAYOUT_FILL_X#|Fox::LAYOUT_FILL_Y
			@r<<h
			#new row has to have as many cols as other rows
			@nc.times{|x| 
				VerticalFrame.new(h){|f| 
					@c[[x,rows-1]]=f 
					f.pad 0,0,0,0
				}
			}
		}
	end
	def cell(x, y); 
		#~ puts [x,y].inspect
		@c[[x,y]]
	end
end
class RadioMutex < FX::VerticalFrame
	__sends__ :event_selected
	def initialize(p)
		init_radio_mutex
		super
		self.layoutHints=0
	end
	include RadioMutexInterface
end

#~~~~~~~~~~~~~~~~~~~~~~~
# the following constant definitions are for backward compatibility
#	they allow to load old rbins
	Menubar=MenuBar
	Toolbar=ToolBar
	Scrollbar=ScrollBar
	Statusbar=StatusBar
	Statusline=StatusLine
	#ToolbarShell=ToolBarShell
	#ToolbarGrip=ToolBarGrip
#~~~~~~~~~~~~~~~~~~~~~~~

end # module FX
class Fox::FXId
	attr_accessor :wdg_name # a user-given name to identify the wdg
	#overwriting app to return the type FX::App instead of the Fox::FXApp
	def app
		return $fxapp
	end
end

class Fox::FXWindow
	def enabled=bool
		bool ? enable : disable
	end
	alias enabled enabled?
	
	def visible=bool
		bool ? show : hide
	end
	alias visible? shown
	alias visible shown
	
	def pad(*args)
		args[0] ? self.padLeft=args[0] :nil
		args[1] ? self.padRight=args[1]:nil
		args[2] ? self.padTop=args[2] :nil
		args[3] ? self.padBottom=args[3] :nil
	end
	def padding
		return [self.padLeft, self.padRight, self.padTop, self.padBottom]
	end
	
	#iterates recursively over all children and executes &block 
	#calls the block also for self
	def recursive(&block) # {|wdg| ... }
		if block_given?
			yield( self)
			self.children.each{|child| child.recursive(&block) }
		end
	end
end
module ImgAccessors
	def img= filename
		raise TypeError unless filename.kind_of? String
		if filename.size>0
			setIcon loadImage( filename)
			@icon_filename=filename
		end
	end
	def img
		@icon_filename.to_s
	end
end
class Fox::FXLabel
	include ImgAccessors
end
class Fox::FXMenuCaption
	include ImgAccessors
end

if __FILE__==$0
	$stdout.sync=true
	c=FX::Color.new 200,10,0,50
	c.from_s(c.to_s)
	puts c.inspect
	c.from_FXColor( c.to_FXColor)
	puts c.inspect
	fd=Fox::FXFontDesc.new.to_s
	app=Fox::FXApp.new "",""
	mw=FX::DialogBox.new app
	check=FX::CheckButton.new mw
	mw.show(0)
	check.connect(Fox::SEL_COMMAND){
		p check.checked?
	}
	check.state=true
	app.create
	app.run
end