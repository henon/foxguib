# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

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
						#@header.setItemOffset i, offset
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

#unit test
if __FILE__==$0
	app=App.new
	mw=MainWindow.new app
	w=TableWidget.new mw
	mw.show(0)
	app.create
	w.set_titles ["title1", "h2", "supadupa-long title"]

	app.run
end
