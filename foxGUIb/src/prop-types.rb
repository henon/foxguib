# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)
require "libGUIb16"
require "code-gen/property-generators"
include Fox
include FX

# for consistency; add dup method to all classes that don't support it (i.e. Nilclass)
class Object 
	def dup 
		return self
	end
end

# seems to be not needed any more
#~ #pasted here to help independent compilation
#~ class HorizontalFrame < Fox::FXHorizontalFrame
	#~ def initialize(p, opts=0)
		#~ super(p, opts|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y, 0,0,0,0,0,0,0,0,0,0)
	#~ end
#~ end

#overwrite dup methods of Hash and Array with a real (recursive) duplication method
class Hash
	def dup
		h={}
		self.each{|k,v| h[k.dup]=v.dup}
		return h
	end
end
class Array
	def dup
		a=self.collect{|e| e.dup}
		return a
	end
end
#abstract property Manipulator base class 
class SuperProp < HorizontalFrame
	def initialize p, method, init_data=nil
		super(p)
		self.layoutHints=LAYOUT_FILL_X
		self.frameStyle=0
		self.pad 0,0,0,0
		# flag for Container to know whether the property should be shown or not
		@visible=true
		@method=method
		@controls=[]
		@enabled=false
		@wdg=nil
		@c=CheckButton.new(self){|c| 
			c.text=""
			c.connect(SEL_COMMAND) {
				set_enabled( @c.state)
			}
		}
		@sep=VerticalSeparator.new( self, SEPARATOR_LINE){|s| s.pad 0,0,0,0 }
		init
		set_enabled false
	end
	attr_reader :method
	attr_reader :enabled
	#the current widget, needet for event callbacks
	attr_accessor :wdg, :visible
	def show
		super if @visible and self.parent.shown?
	end
	#to be overridden by subclasses
	def init
		method_label
	end
	def method_label
		l=Label.new(self){|l| 
			l.text=@method 
			@controls << l 
		}
	end		
	#a text manipulator for textual properties
	def text_input
		@tf=TextField.new(self){|tf| 
			tf.layoutHints=LAYOUT_RIGHT
			tf.numColumns=5
			tf.disable
			tf.connect(SEL_COMMAND) {
				@wdg.update_wdg self if @wdg
			}
			tf.connect(SEL_CHANGED) {
				@wdg.update_wdg self 
			}
			@controls << tf 
		}
		@tf
	end
	#a little texteditor dialog
	def texteditor p
		@texted=DialogBox.new p
		@texted.resize(200,150)
		VerticalFrame.new(@texted){|v|
			v.pad 4,4,4,4
			VerticalFrame.new(v){|tfr|
				tfr.frameStyle=FRAME_SUNKEN
				tfr.pad 0,0,0,0
				@text=Text.new(tfr){|t|
					t.text=@tf.text
				}
			}
			HorizontalFrame.new(v){|h|
				Button.new(h, LAYOUT_RIGHT){|b|
					b.text="Apply"
					b.connect(SEL_COMMAND){
						@tf.text=@text.text
						@wdg.update_wdg self if @wdg
						@texted.destroy
					}
				}
				Button.new(h, LAYOUT_RIGHT){|b|
					b.text="Cancel"
					b.connect(SEL_COMMAND){
						@texted.destroy
					}
				}
			}
		}
		@texted.create
		@texted.show(PLACEMENT_CURSOR)
	end
	#gets the data from the property widget
	def get_data
		begin
			data=deserialize(@tf.text)
			@tf.textColor=FXRGB(0,0,0)
			return data
		rescue Exception
			@tf.textColor=FXRGB(255,0,0)
		end if @tf
	end
	#sets the data value of the property widget
	def set_data data
		if @tf
			@tf.textColor=FXRGB(0,0,0)
			@tf.text=serialize(data)
		end
	end
	#resets the widget and the prop-widget to the default state
	def reset_default
		@wdg.reset_default self if @wdg
	end
	#enables or disables the PropWidget
	def set_enabled bool
		reset_default unless bool
		@enabled=bool
		@c.state=bool 
		@controls.each{|w|
			w.enabled=bool
			change_text_color(w, bool)
		}
	end
	#changes the text color of the prop-widget, so that it appears disabled or enabled
	def change_text_color w, t
		return unless w.respond_to? "textColor="
		if t
			w.textColor=FXRGB(0,0,0)
		else
			w.textColor=FXRGB(100,100,100)
		end
	end
	def serialize data
		data
	end
	def deserialize data
		data
	end
end

class NameProp < SuperProp
	def initialize p
		super(p, "Name:")
		@c.hide
		@sep.hide
		method_label
		text_input		
		@tf.enable
		@tf.connect(SEL_CHANGED){
			@tf.textColor=FXRGB(255,0,0)
		}
		@tf.numColumns=15
		@tf.connect(SEL_COMMAND) {
			begin
				@tf.textColor=FXRGB(0,0,0) if @wdg.userData.manager.rename_wdg @wdg, @tf.text
			rescue Exception
				puts "oops, trying to rename a deleted widget!"
			end
		}
	end
	def init; end
end
class StringProp < SuperProp
	include StringPropCodeGen
	def init
		super
		Button.new(self){|b| 
			b.text="..." 
			b.layoutHints=LAYOUT_RIGHT
			b.connect(SEL_COMMAND){
				texteditor self
			}
			@controls<<b
		}
		text_input
		@tf.numColumns=15
	end
end
class IntProp < SuperProp
	include IntPropCodeGen	
	def init
		method_label
		text_input
	end
	def deserialize data
		return data.to_i
	end
end
class BoolProp < SuperProp
	include BoolPropCodeGen
	def init
		method_label
		@ck=CheckButton.new(self){|c| 
			#~ c.checkState=@datum
			c.text=''
			c.layoutHints=LAYOUT_RIGHT
			c.disable
			c.connect(SEL_COMMAND) {
				@wdg.update_wdg self if @wdg			
			}
		}
		@controls<<@ck
	end
	def get_data
		return @ck.state
	end
	def set_data data
		@ck.state=data
	end
end


class ColorProp< SuperProp
	include ColorPropCodeGen
	def init
		method_label
		VerticalFrame.new(self){|pa|
			pa.pad 0,0,0,0
			pa.frameStyle=FRAME_LINE
			pa.layoutHints=LAYOUT_RIGHT
			@b=Button.new(pa){|b| 
				b.text=" C "
				b.frameStyle=FRAME_NONE
				b.connect(SEL_COMMAND){
					$color_dlg.rgba=deserialize(@tf.text)
					if $color_dlg.execute==1
						set_data $color_dlg.getRGBA()
						@wdg.update_wdg self if @wdg			
					end
				}
				@controls<<b
			}
		}
		text_input
		@tf.numColumns=15
	end
	def get_data
		color=super
		@b.backColor=color if color
		return color
	end
	def set_data( color)
		super
		@b.backColor=color
	end
	def serialize data
		Color.new.from_FXColor(data).to_s
	end
	def deserialize data
		Color.new.from_s(data).to_FXColor
	end
end
class FontProp < SuperProp
	include FontPropCodeGen
	def init
		method_label
		VerticalFrame.new(self){|pa|
			pa.pad 0,0,0,0
			pa.frameStyle=FRAME_LINE
			pa.layoutHints=LAYOUT_RIGHT
			@b=Button.new(pa){|b| 
				b.text=" F "
				b.frameStyle=FRAME_NONE
				b.connect(SEL_COMMAND){
					fd=Fox::FXFontDesc.new
					$font_dlg.fontSelection=fd.from_s( @tf.text)
					if $font_dlg.execute==1
						fd=$font_dlg.fontSelection 
						font=Font.new
						font.fd=fd
						@tf.text=fd.to_s
						@wdg.update_wdg self if @wdg			
					end
				}
				@controls<<b
			}
		}
		text_input
		@tf.numColumns=15
	end
	def serialize data
		data.fontDesc.to_s
	end
	def deserialize data
		Font.new.from_s(data).to_FXFont
	end
end
class ConstProp < SuperProp
	include ConstPropCodeGen
	def initialize p, method, array
		@array=array
		super
	end
	def init
		method_label
		dropdown
	end
	def dropdown
		@b=MenuButton.new(self){|b|
			@controls<<b
			b.text=''
			b.layoutHints=LAYOUT_RIGHT
		}
		@checklist=[]
		Popup.new( @b){|popup|
			@b.menu=popup
			popup.connect(SEL_MAP){
				state=@wdg.send(@method.chop) if @wdg
				set_data state
			}
			VerticalFrame.new( popup){|v|
				@array.each{|const|
					CheckButton.new( v){|c|
						@checklist<<c
						c.text=const
						c.layoutHints=LAYOUT_LEFT
						c.connect(SEL_COMMAND) {
							@wdg.update_wdg self if @wdg			
						}
					}
				}
			}
			HorizontalSeparator.new popup
			MenuCommand.new( popup){|ok| ok.text= 'OK' }
			HorizontalSeparator.new popup
			Button.new( popup){|checkall| 
				checkall.text='check all' 
				checkall.frameStyle=FRAME_NONE
				checkall.connect(SEL_COMMAND) { checkall true}
			}
			Button.new( popup){|uncheckall| 
				uncheckall.text='uncheck all' 
				uncheckall.frameStyle=FRAME_NONE
				uncheckall.connect(SEL_COMMAND) { checkall false}
			}
		}
	end
	def get_data
		a=[]
		@checklist.each{|c|
			a<<'Fox::'+c.text if c.state
		}
		state=eval( a.join('|'))
		state ? state : 0
	end	
	def set_data( state)
		return unless @wdg
		@wdg.send( @method, 0) 
		sticky=@wdg.send( @method.chop)
		@wdg.send( @method, eval(@array.join('|')))
		unmod=@wdg.send( @method.chop)
		@wdg.send( @method, state)
		@checklist.each{|child|
			const=eval(child.text)
			state&const==const ? child.check=true : child.check=false
			child.disable if sticky&const==const
			child.disable unless unmod&const==const 
		}
	end
	def checkall b
		a=[]
		@checklist.each {|child|
			child.check=b if child.enabled
			a << child.text
		}
		state=eval( a.join('|'))
		@wdg.update_wdg self if @wdg			
	end
end
class IconProp < SuperProp
	include IconPropCodeGen
	def init
		super
		Button.new(self){|b| 
			b.text="..." 
			b.layoutHints=LAYOUT_RIGHT
			b.connect(SEL_COMMAND){
				dlg=IconDialog.new self
				filename=dlg.start
				set_data deserialize( filename)
				@wdg.update_wdg self if @wdg
			}
			@controls<<b
		}
		text_input
		@tf.numColumns=15
	end
	#~ def deserialize data
		#~ Icon.new(data).img
		#~ fail unless File.exist?( data)
		#~ return data
	#~ end
end
class RangeProp < SuperProp
	include RangePropCodeGen
	def init
		super
		text_input
		@tf.numColumns=15
		@tf.connect(SEL_CHANGED){
			update
		}
		@tf.connect(SEL_COMMAND) {
			update
		}
	end
	def update
		begin
			range=deserialize( @tf.text)
			@wdg.update_wdg self if @wdg
			@tf.textColor=FXRGB(0,0,0)
		rescue Exception
			@tf.textColor=FXRGB(255,0,0)
			puts $!
			puts $!.backtrace
		end
	end
	def deserialize data
		begin
			range=eval(data)
			fail unless range.kind_of? Range
			fail unless range.first.kind_of? Numeric
			fail unless range.last.kind_of? Numeric
		rescue Exception
			range=0..0
			puts $!
			puts $!.backtrace
		end
		return range
	end
	def serialize data
		data.inspect
	end
end

#unit testing code
if __FILE__==$0
	require "minitest"
	test("Range Property Manipulator") {
		app=FX::App.new
		w=FX::MainWindow.new app
		s=FX::Spinner.new w
		rangeInst=RangeProp.new(s,"range")
		#testing deserialize
		assert_equal 1..10, rangeInst.deserialize( "1..10")
		assert_raises(RuntimeError){ 
			rangeInst.deserialize( '0')
		}
		assert_equal "-37..100", rangeInst.serialize( -37..100) 
		aRange=1..2
		rangeInst.set_data( aRange)
		assert_equal aRange, rangeInst.get_data
		true
	}
	
	test("Color Property Manipulator") {
		app=FX::App.new
		w=FX::MainWindow.new app
		v=FX::VerticalFrame.new w
		colorInst=ColorProp.new(v,"color")
		color_data="255,255,255,255"
		#trying to get data before setting
		data=colorInst.get_data
		assert_equal 0,data
		#testing deserialize and serialize
		ser_data=colorInst.serialize(deser_data=colorInst.deserialize(color_data))
		assert_equal color_data,ser_data
		#testing get and set data
		colorInst.set_data(colorInst.deserialize(color_data))
		ser_data=colorInst.serialize(data=colorInst.get_data)
		assert_equal color_data,ser_data
		true
	}
	
	test("Font Property Manipulator") {
		app=FX::App.new
		w=FX::MainWindow.new app
		t=FX::Text.new w
		fontInst=FontProp.new(t,"font")
		font_data = "Tahoma"
		#testing serialize and deserialize
		ser_data=fontInst.serialize(deser_data=fontInst.deserialize(font_data))
		assert_equal Font.new.from_s(font_data).to_s,ser_data
		true
	}
	   
	test("Boolean Property Manipulator") {
		app=FX::App.new
		w=FX::MainWindow.new app
		t=FX::Text.new w
		boolInst=BoolProp.new(t,"bool")
		bool_data=true
		#getting data before setting it
		assert_equal false,boolInst.get_data
		#getting and setting data
		boolInst.set_data bool_data
		assert_equal bool_data,boolInst.get_data
		true
	}
	
	test("Super Property Manipulator") {
		app=FX::App.new
		w=FX::MainWindow.new app
		t=FX::Text.new w
		superInst=SuperProp.new(t,"super")
		data="string"
		#testing serialize and deserialize
		ser_data=superInst.serialize superInst.deserialize(data)
		assert_equal data,ser_data
		#getting data before setting it
		assert_nil superInst.get_data
		assert_equal false,superInst.enabled
		#enabling the property and testing get data before setting data
		superInst.set_enabled true
		assert_nil superInst.get_data
		#setting and getting data
		superInst.text_input
		type_array=[
			5,
			"string",
			true,
			ColorProp.new(t,"color").deserialize("255,255,255,255"),
			FontProp.new(t,"font").deserialize("Tahoma"),
			1..5
		]
		type_array.each{|var|
			superInst.set_data var
			assert_equal var.to_s,superInst.get_data
		}
		true
	}
	
end
