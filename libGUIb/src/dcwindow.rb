# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "event_listener"
require "fxbase"
module FX
#adding support for variable origin to DC, which allows drawing with relative coordinates
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
if __FILE__==$0
	$stdout.sync=true
	include FX
	app=App.new
	mw=MainWindow.new app
	canvas=DrawingCanvas.new mw
	canvas.on_draw{|dc, event, c|
		dc.fillRectangle 0, 0, canvas.width, canvas.height
	}
	mw.resize 400, 300
	mw.show
	app.create
	app.run
end
