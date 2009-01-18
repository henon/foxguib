# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

# generator extension for widgets
#~ module WidgetGenerator
	
	
#~ end

class Fox::FXWindow
	#~ include WidgetGenerator
	# iterates over the widgets properties and yields { |method, Property_manipulator, | ... }
	def generate_properties
		PropMan.instance.props.each{|m,manip|
			if @defaults.keys.member? m
				value=send( m.chop)
				manip.wdg=self
				unless value.to_s==@defaults[m].to_s
					yield( manip) if block_given?
				end
			end
		}
	end
end
