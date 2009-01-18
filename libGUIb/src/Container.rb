# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

if __FILE__==$0
	Dir.chdir ".."
	require 'FX'
end

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
#unit test
if __FILE__==$0
	app=App.new
	mw=MainWindow.new app
	w=Container.new mw
	#~ w.header.iconPosition=ICON_AFTER_TEXT
	w.layoutHints=LAYOUT_FIX_WIDTH
	w.width=150
	w.header.text="header"
	Button.new w
	mw.show(0)
	app.create
	app.run
end
