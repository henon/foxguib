# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "event_listener"

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
			begin
				w.state=(w==@selected) # only the selected widget is checked.
			rescue Exception 
				# this is necessary to prevent a radiomutex from crashing 
				# after a radiobutton has been deleted in foxGUIb
				puts $!
			end
		end
	end
	def selected
		return @selected
	end
end
end #fx

if __FILE__==$0
	$app=FX::App.new "", ""
	FX::MainWindow.new( $app){||
	}
	
	$app.create
	$app.run
end