# libGUIb: Copyright (c) by Meinrad Recheis aka Henon, 2006
# THIS SOFTWARE IS PROVIDED IN THE HOPE THAT IT WILL BE USEFUL
# WITHOUT ANY IMPLIED WARRANTY OR FITNESS FOR ANY PURPOSE.
$VERBOSE=nil #<--- this is to overcome a bug in ruby 1.8.x that yields a whole lot of warnings when loading fxruby
require  'fox14'
def rel_path(a, b)
	raise TypeError unless (a.kind_of? String and b.kind_of? String)
	a.gsub!(/\\/,'/')
	b.gsub!(/\\/,'/')
	a = a.split('/')
	b = b.split('/')
	i = 0
	while ((a[i] == b[i]) && (i < a.size))
	i += 1
	end
	'../'*(a.size - i) + b[i..-1].join('/')
end
module FX
class App < Fox::FXApp
	def initialize a="",b=""
		super
		@created=false
		$app=$fxapp=self
	end
	def create(*args)
		super
		@created=true
	end
	def created?()
		return @created
	end
end
end #FX
module MiddleBtn
	def handleMMB_Events
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONPRESS,   0, :onMiddleBtnPress)
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONRELEASE, 0, :onMiddleBtnRelease)
	end
	def onMiddleBtnPress(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self, MKUINT(selector, Fox::SEL_MIDDLEBUTTONPRESS), evt) != 0)
				return 1
			end
		end
		return 0
	end
	def onMiddleBtnRelease(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self,MKUINT(selector, Fox::SEL_MIDDLEBUTTONRELEASE), evt) != 0)
				return 1
			end
		end
		return 0
	end
end
module RightBtn
	def handleRMB_Events
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONPRESS,   0, :onMiddleBtnPress)
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONRELEASE, 0, :onMiddleBtnRelease)
	end
	def onRightBtnPress(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self, MKUINT(selector, Fox::SEL_RIGHTBUTTONPRESS), evt) != 0)
				return 1
			end
		end
		return 0
	end
	def onRightBtnRelease(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self,MKUINT(selector, Fox::SEL_RIGHTBUTTONRELEASE), evt) != 0)
				return 1
			end
		end
		return 0
	end
end
def loadImageToString filename
	data=nil
	File.open( filename, "rb"){|f| data=f.read }
	return data.unpack("h#{data.size*2}")[0]
end
def loadImageFromString s, icon_class=Fox::FXPNGIcon
	raise TypeError unless $fxapp
	imgdata= [s].pack( "h#{s.size*2}")
	img=icon_class.new($fxapp, imgdata, Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP)
	img.create
	return img
end
def load_dummy
	raise TypeError unless $fxapp
	imgdata="9805e474d0a0a1a0000000d0948444250000000100000001803000000082d2f035000000a247548547342756164796f6e6024596d65600d4f60293026456260223030343021363a33363a3133302b2031303037c63ded4000000704794d454704d2090f0627041559b9c00000090078495370000b0210000b021102ddde7cf000000407614d41400001bf8b0cf16500000003305c44554000000ffefeffff0f0ffc1c1ffcbcbff7878ff5b5bffc5c5ff7979ff9292ffadadff2f2fff7171ff4747ffb4b4ff6e6eff8383bfe98b0d000000104725e43500046e8d66000000b59444144587ad58ec1ee008028040069333b223d7ff7adec6a39c5b57f38d8f406a3992ea61d0508294b382bda9d373840c595953630f0c1c930ece73e940ee8506f8dc0446f14600fddfa260877711b0c50971c4f5ff898f7819b1678020e2a25402a2000000009454e444ea240628"
	imgdata= [imgdata].pack( "h#{imgdata.size*2}")
	$dummy_img=img=Fox::FXPNGIcon.new($fxapp, imgdata, Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP)
	img.create
	return img
end
def hasExtension(filename, ext)
	File.basename(filename, ext) != File.basename(filename)
end
def loadImage(file)
	img=load_dummy unless $dummy_img
	unless File.exists? file 
		return img
	end
	begin
		opts=Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP
		if hasExtension(file, ".gif")
			img = Fox::FXGIFIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".bmp")
			img = Fox::FXBMPIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".xpm")
			img = Fox::FXXPMIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".png")
			img = Fox::FXPNGIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".jpg")
			img = Fox::FXJPGIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".pcx")
			img = Fox::FXPCXIcon.new($fxapp, nil,opts)
		elsif hasExtension(file, ".tif")
			img = Fox::FXTIFIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".tga")
			img = Fox::FXTGAIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".ico")
			img = Fox::FXICOIcon.new($fxapp, nil, opts)
		end
		unless img
			puts("Unsupported image type: #{file}")
			return img
		end
		Fox::FXFileStream.open(file, Fox::FXStreamLoad) { |stream| img.loadPixels(stream) }
		img.filename=file
		img.create
	rescue Exception
		puts "load Image: #{$!}"
	end
	img
end
module FX
class Icon
		def initialize filename
			if filename
				@filename=filename
				@img=loadImage(filename)
			end
		end
	attr_accessor :img
	def to_s
		@filename
	end
		def Icon.LoadFromString s, icon_class=Fox::FXPNGIcon
			icon=Icon.new nil
			icon.img=loadImageFromString s, icon_class
			return icon
		end
	end
class Color
	attr_accessor :r, :g, :b, :a
	def initialize r=0, g=0, b=0, a=nil
		@r,@g,@b,@a=r,g,b,a
	end
	def to_FXColor
		@a ? Fox::FXRGBA(@r,@g,@b,@a) : Fox::FXRGB(@r,@g,@b)
	end
	def from_FXColor c
		@r=Fox::FXREDVAL(c)
		@g=Fox::FXGREENVAL(c)
		@b=Fox::FXBLUEVAL(c)
		@a=Fox::FXALPHAVAL(c)
		self
	end
	def from_name( name)
		from_FXColor( Fox::fxcolorfromname( name))
		self
	end
	def serialize
		Fox::fxencodeColorData(to_FXColor)
	end
	def deserialize(data)
		from_FXColor( Fox::fxdecodeColorData(data))
		self
	end
	def to_s
		(@a ? [@r,@g,@b,@a] : [@r,@g,@b]).join(',')
	end
	def from_s s
		s= "0, 0, 0, 0" if s.size<5
		@r,@g,@b,@a=s.split(',').collect{|c| c.to_i}
		self
	end
	end
	class Font
		def initialize
			@fd=Fox::FXFontDesc.new
		end
		attr_accessor :fd
		def to_s
			@fd.to_s
		end
		def from_s s
			@fd.from_s s
			self
		end
		def to_FXFont
			f=Fox::FXFont.new $fxapp, @fd
			f.create
			f
		end
		def from_FXFont f
			@fd=f.fontDesc
			self
		end
	end
end # module
class Fox::FXIcon
	attr_accessor :filename
	def to_s
		filename ? filename : ''
	end
end
class Fox::FXFontDesc
	def to_s
		[self.face, 
		self.size, 
		self.weight, 
		self.slant, 
		self.encoding, 
		self.setwidth, 
		self.flags].join( '|')
	end
	def from_s( s )
		begin
			a=s.split('|')
			self.face=a[0] 
			self.size=a[1].to_i
			self.weight=a[2].to_i
			self.slant=a[3].to_i
			self.encoding=a[4].to_i
			self.setwidth=a[5].to_i
			self.flags=a[6].to_i
		rescue Exception
			puts "error parsing string representation: #{$!}"
			puts $!.backtrace.join($/)
			return nil
		end
		self
	end
	def init fd
		if fd.kind_of? Fox::FXFontDesc
			self.face=fd.face
			self.size=fd.size
			self.weight=fd.weight
			self.slant=fd.slant
			self.encoding=fd.encoding
			self.setwidth=fd.setwidth
			self.flags=fd.flags
		elsif fd.kind_of? String
			from_s fd
		end
	end
end
class Fox::FXFont
	def to_s
		fontDesc.to_s
	end
end
class Fox::FXIcon
	attr_accessor :filename
	def to_s
		filename ? filename : ''
	end
end
class Module
    def __sends__ *args
        args.each { |arg|
            class_eval <<-CEEND
                def on_#{arg}(&callback)
                    @#{arg}_observers ||= {}
                    @#{arg}_observers[caller[0]]=callback
		    return caller[0]
                end
		def del_#{arg}(id)
			@#{arg}_observers ||= {}
			return @#{arg}_observers.delete( id)
		end
                private
                def #{arg} *the_args
                    @#{arg}_observers ||= {}
                    @#{arg}_observers.each { |caller, cb|
                        cb.call *the_args
                    }
                end
            CEEND
        }
    end
end
module FX
class RadioGroup
	__sends__ :event_selected
	def initialize
		@radio_widgets=[]
		@selected=nil
	end
	attr_reader :radio_widgets
	def add_radio(radio_widget, &block)
		@radio_widgets<<radio_widget
		radio_widget.connect(Fox::SEL_COMMAND){
			select( radio_widget)
			yield if block_given?
		}
	end
	alias << add_radio
	def select radio_widget
		@selected=radio_widget
		event_selected @selected
		for w in @radio_widgets
			w.state=(w==@selected) # only the selected widget is checked.
		end
	end
	def selected
		return @selected
	end
end
end #fx
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
		self.currentItem=c
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
		super(p, 'title', Fox::DECOR_ALL)
		pad(0,0,0,0)
		handleMMB_Events
	end
	include Responder
	include MiddleBtn
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
		self.pad 2,2,2,2
	end
	def rows; @r.size; end
	def cols; @nc; end
	def size=(w, h)
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
			@nc.times{|x| 
				VerticalFrame.new(h){|f| 
					@c[[x,rows-1]]=f 
					f.pad 0,0,0,0
				}
			}
		}
	end
	def cell(x, y); 
		@c[[x,y]]
	end
end
class RadioMutex < FX::VerticalFrame
	__sends__ :event_selected
	def initialize(p)
		init_radio_mutex
		super
	end
	include RadioMutexInterface
end
	Menubar=MenuBar
	Toolbar=ToolBar
	Scrollbar=ScrollBar
	Statusbar=StatusBar
	Statusline=StatusLine
end # module FX
class Fox::FXId
	attr_accessor :wdg_name # a user-given name to identify the wdg
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
class FileSelector
	def initialize( parent)
		construct_widget_tree( parent)
		init if respond_to? 'init'
	end
	def construct_widget_tree( parent)
		@topwin=
		FX::HorizontalFrame.new(parent){|w|
			@FileSelector=w
			w.padLeft=0
			w.frameStyle=0
			w.padRight=0
			w.hSpacing=2
			w.height=21
			w.layoutHints=1024
			FX::Label.new(@FileSelector){|w|
				@label=w
				w.text="File:"
				w.width=24
				w.x=0
			}
			FX::TextField.new(@FileSelector){|w|
				@textfield=w
				w.width=297
				w.y=0
				w.layoutHints=1024
				w.x=26
			}
			FX::Button.new(@FileSelector){|w|
				@browse=w
				w.text="Browse..."
				w.padLeft=4
				w.width=59
				w.padRight=4
				w.y=0
				w.x=325
			}
		}
	end
	attr_accessor :topwin,
	:FileSelector,
	:label,
	:textfield,
	:browse,
	:__foxGUIb__last__
end
class FileSelector
	def init
		@title="File Dialog"
		@relative_path=false
		@filename=""
		@directory=Dir.getwd
		@dialog = Fox::FXFileDialog.new(@topwin, @title)
		@patterns = ["All Files (*)"]
		@currentPattern=0		
		@browse.connect(Fox::SEL_COMMAND, method( :onBrowse))
	end
	attr_accessor :directory, :patterns, :currentPattern, :title, :filename, :relative_path
	attr_accessor :onNewFilenameBlock
	def description=text
		@label.text=text
	end
	def description
		@label.text
	end
	def onBrowse(*args)
		@dialog.title=@title
		@dialog.directory=@directory
		@dialog.patternList = @patterns
		@currentPattern=0 if @currentPattern >= @patterns.size
		@dialog.currentPattern= @currentPattern
		@dialog.filename=filename.to_s
		if @dialog.execute != 0
			if @relative_path
				@filename=@textfield.text=rel_path( Dir.getwd, @dialog.filename)
			else
				@filename=@textfield.text=@dialog.filename
			end
			@onNewFilenameBlock.call if @onNewFilenameBlock.respond_to? "call"
		end
	end
end
class PathSelector
	def initialize( parent)
		construct_widget_tree( parent)
		init if respond_to? 'init'
	end
	def construct_widget_tree( parent)
		@topwin=
		FX::HorizontalFrame.new(parent){|w|
			@PathSelector=w
			w.padLeft=0
			w.frameStyle=0
			w.padRight=0
			w.hSpacing=2
			w.height=21
			w.layoutHints=1024
			FX::Label.new(@PathSelector){|w|
				@label=w
				w.text="Path:"
				w.width=30
				w.x=0
			}
			FX::TextField.new(@PathSelector){|w|
				@textfield=w
				w.width=291
				w.y=0
				w.layoutHints=1024
				w.x=32
			}
			FX::Button.new(@PathSelector){|w|
				@browse=w
				w.text="Browse..."
				w.padLeft=4
				w.width=59
				w.padRight=4
				w.y=0
				w.x=325
			}
		}
	end
	attr_accessor :topwin,
	:PathSelector,
	:label,
	:textfield,
	:browse,
	:__foxGUIb__last__
end
s='PathSelector-extension.rb'
require s if File.exist?(s)
module FX
	class Container < FX::VerticalFrame
		attr_reader :header, :hsep
		def initialize( parent)
			super
			boxMinusPNG_Str=
			"9805e474d0a0a1a0000000d09484442500000090000000904030000010568bb25b000000704794d4"+
			"54704d50016041822c41f2b600000090078495370000b0210000b021102ddde7cf000000407614d4"+
			"1400001bf8b0cf16500000009005c44554484848ffffff0000003e75793f000000229444144587ad"+
			"3606082062011a404cc82801c0402828c024a80221c2c28288584000525c10091d50980600000000"+
			"9454e444ea240628"
			boxPlusPNG_Str=
			"9805e474d0a0a1a0000000d09484442500000090000000904030000010568bb25b000000704794d4"+
			"54704d50016041c0ef71bcab00000090078495370000b0210000b021102ddde7cf000000407614d4"+
			"1400001bf8b0cf16500000009005c44554484848ffffff0000003e75793f000000729444144587ad"+
			"3606082062011a404cc8a801c0402828c024a8022142c2802a91505119840a8000c25a100daa1682"+
			"d9000000009454e444ea240628"
			self.padLeft=0
			self.frameStyle=12288
			self.layoutHints=Fox::LAYOUT_FILL_X
			self.padRight=0
			@openIcon=Icon.LoadFromString boxMinusPNG_Str
			@closedIcon=Icon.LoadFromString boxPlusPNG_Str
			FX::Label.new(self){|w|
				@header=w
				w.layoutHints=Fox::LAYOUT_FILL_X
				w.iconPosition=Fox::ICON_BEFORE_TEXT
				w.justify=Fox::JUSTIFY_LEFT
				w.icon=@openIcon.img
				@open=true
			}
			FX::HorizontalSeparator.new(self){|w|
				@hsep=w
				w.padLeft=0
				w.padRight=0
			}
			@header.connect(SEL_LEFTBUTTONPRESS) {
				if @open
					close_body
				else
					open_body
				end
			}
		end
		def close_body
			@open=false
			@header.icon=@closedIcon.img
			self.children.each{|ch|
				next if ch==@header
				ch.hide
			}
			if self.layoutHints&LAYOUT_FILL_Y==LAYOUT_FILL_Y
				self.layoutHints-=LAYOUT_FILL_Y
				@fill_y=true
			else
				@fill_y=false
			end
			self.recalc
		end
		def open_body
			@open=true
			@header.icon=@openIcon.img
			self.children.each{|ch|
				next if ch==@header
				ch.show
			}
			self.layoutHints|=LAYOUT_FILL_Y if @fill_y
			self.recalc
		end
		def title=(text)
			@header.text=text
		end
		def title
			@header.text
		end
	end
end
module RadioGroup1
	def RadioGroup1_initialize
		@RadioGroup1_initialized=true
		@RadioGroup1_listeners=[] unless @RadioGroup1_listeners
	end
	def radio_command w
		RadioGroup1_initialize unless @RadioGroup1_initialized
		return if @selected_radio_widget==w
		if @selected_radio_widget
			@selected_radio_widget.set_radio_state false
		end
		@selected_radio_widget=w 
		@RadioGroup1_listeners.each{|l|
			l.on_event( @selected_radio_widget)
		}
	end
	attr_accessor :selected_radio_widget, :RadioGroup1_listeners
end
module RadioWidget
	def radio_initialize col=FX::Color.new(255,255,255)
		@radio_initialized=true
		@radioBackColor=FX::Color.new.from_FXColor(self.backColor)
		@radioSelectColor=col unless @radioSelectColor
		@state=false
		connect(SEL_LEFTBUTTONPRESS, method( :lmb_press))
	end
	attr_accessor :radioSelectColor, :radioSelectColor
	def set_radio_state state
		@state=state
		change_radio_selection
	end
	def change_radio_selection
		self.backColor=@state ? @radioSelectColor.to_FXColor : @radioBackColor.to_FXColor
	end
	attr_accessor :state, :group, :lmbdown
	def lmb_press(*args)
		if @group and @group.respond_to?( "radio_command")
			set_radio_state true
			@group.radio_command(self) 
		else
			set_radio_state( !@state)
		end
		@lmbdown=true
		0
	end
end
module FX
	class RadioMatrix < Fox::FXMatrix
		include RadioGroup1
		def initialize( p)
			super( p)
		end
	end
	class RadioLabel < Label
		include RadioWidget
		def initialize(p)
			super(p)
			radio_initialize
		end
	end
end
module FX
	class TableWidget < FX::VerticalFrame
		HEADER_COLOR=Fox::FXRGB(200,200,200)
		def initialize(*args)
			super
			@autoresize_titles=true
			Header.new(self){|w|
				@header=w
				w.headerStyle=HEADER_HORIZONTAL|HEADER_TRACKING
				w.frameStyle=0
				w.backColor=HEADER_COLOR
				w.connect(SEL_CONFIGURE) {
					set_title_widths
				}
				w.layoutHints=LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT
				w.height=20
			}
			FXMatrix.new(self,1){|w|
				@matrix=w
			}
		end
		attr_accessor :autoresize_titles
		def create
			super
		end
		def set_titles stringarr
			stringarr.each{|str|
				@header.appendItem(" "+str)
			}
			set_cols stringarr.size
			set_title_widths 
		end
		def set_title_widths numarray=nil
			if numarray
			else # ok, calculate the item widths from their titles
				total=0
				totalsize=0
				i=0
				@header.each{|item|
					total+=item.text.size
					totalsize+=item.size
					item.data=i
					i+=1
				}
				if @autoresize_titles or totalsize==0
					quant=(@header.width/total.to_f)
					offset=0
					@header.each{|item|
						i=item.data
						size=(item.text.size*quant).to_i
						@header.setItemSize i, size
						offset+=size
					}
				end
			end
		end
		def set_cols n
		end
		def set_rows n
		end
	end
end
class StyleVisitor
	def apply_to( widget, recursive=true)
		widget.recursive{|w|
			identifier="#{w.class.to_s.gsub( /Fox|::|FX/, '')}_style"
			send identifier, w #if respond_to? identifier
			break unless recursive
		}
	end
end
class FlatStyle < StyleVisitor
	attr_accessor :frameColor
	def initialize
		@frameColor=Fox::FXRGB 0,0,0
		@backColor=Fox::FXRGB 230,230,230
	end
	def Button_style w
		w.frameStyle=Fox::FRAME_LINE
		w.hiliteColor=@frameColor
		w.shadowColor=@frameColor
		w.backColor=@backColor
	end
	def TextField_style w
		w.frameStyle=Fox::FRAME_LINE
		w.borderColor=Fox::FXRGB 168,168,168
	end
	def method_missing(*args)
		identifier, w = args
		unless identifier.to_s =~ /style/
			raise args.join( ",")
		end
		w.backColor=@backColor
	end
end
module FX
class DCWindow < Fox::FXDCWindow
	def initialize(*args)
		super
		setOrigin( 0, 0)
	end
	def getOrigin
		return @xOrigin, @yOrigin
	end
	def setOrigin x=0,y=0
		@xOrigin=x
		@yOrigin=y
		@originStack=[x,y]
	end
	def pushOrigin x=0, y=0
		@xOrigin+=x
		@yOrigin+=y
		@originStack.push [@xOrigin, @yOrigin]
	end
	def popOrigin
		@originStack.pop if @originStack.size > 1
		@xOrigin,@yOrigin=@originStack.last
	end
	def drawText x, y, text, bg=false
		unless bg
			super( @xOrigin+x, @yOrigin+y, text)
		else
			drawImageText( @xOrigin+x, @yOrigin+y, text)
		end
	end
	def drawImageText x, y, text
		super( @xOrigin+x, @yOrigin+y, text)
	end
	def drawLine x, y, x1, y1
		super( @xOrigin+x, @yOrigin+y, @xOrigin+x1, @yOrigin+y1)
	end
	def fillRectangle x, y, w, h
		super( @xOrigin+x, @yOrigin+y, w, h)
	end
	def drawRectangle x, y, w, h 
		super( @xOrigin+x, @yOrigin+y, w, h)
	end
end
class DrawingCanvas < Canvas
	__sends__ :event_draw
	def initialize parent
		super parent, Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y
		@stdFont=Fox::FXFont.new($fxapp, "[helvetica] 90 700 1 1 0 0")
		@stdFont.create
		self.connect(Fox::SEL_PAINT){|sender, sel, event|
			self.resize parent.width, parent.height if self.width!=parent.width or self.height!=parent.height
			dc=DCWindow.new self
			dc.font=@stdFont
			event_draw( dc, event, self )
			dc.end
		}
	end
end
end
class PathSelector
	def init
		@title="Directory Dialog"
		@relative_path=false
		@directory=Dir.getwd
		update(@directory)
		@dialog = FXDirDialog.new(@topwin, @title)
		@browse.connect(SEL_COMMAND, method( :onBrowse))
	end
	attr_accessor  :directory, :title, :filename, :relative_path
	def description=text
		@label.text=text
	end
	def description
		@label.text
	end	
	def onBrowse(*args)
		@dialog.title=@title
		@dialog.directory=@directory
		if @dialog.execute != 0
			update(@dialog.directory)
		end
	end
	def update(path)
		if @relative_path
			@directory=@textfield.text=rel_path( Dir.getwd, path)
		else
			@directory=@textfield.text=path
		end
	end
end
