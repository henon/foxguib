# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)


if __FILE__==$0
	Dir.chdir ".."
	require "FX"
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

#unit test
if __FILE__==$0
	$stdout.sync=true
	app=App.new
	w=MainWindow.new app
	RadioMatrix.new(w){|lm|
		lm.matrixStyle=MATRIX_BY_COLUMNS
		lm.numColumns=3
		10.times{|i|
			RadioLabel.new(lm){|l| 
				l.group=lm
				l.text=i.to_s
				l.img="FX/icon_not_found.png"
			}
		}
	}
	w.show(0)
	app.create
	app.run
end