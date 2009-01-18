# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

#extension module for Fox::FXWindow that is only mixed in at foxGUIb runtime.
module Properties
	def create_defaults
		#@defaults: { method_string=> default-value }
		@defaults={}
		@wdgprops=[] unless @wdgprops
		for proplist in [$color_props,$general_props,$const_props,@wdgprops]
			proplist.each{|method, type, array|
				next unless self.respond_to? method
				@defaults[method]=send(method.chop)
				@defaults[method]=1 if method.chop == "numColumns"
			}
		end
	end
	#list of property objects
	attr_reader :defaults
	
	#load the properties of the widget into the property manager
	def update_properties 
		PropMan.instance.nameProp.wdg=self
		PropMan.instance.nameProp.set_data userData.treeitem.to_s
		PropMan.instance.type_lbl.text=self.class.to_s
		PropMan.instance.props.each{|m,manip|
			if @defaults.keys.member? m
				
				next unless self.respond_to?( m.chop )
				value=send( m.chop)
				manip.wdg=self
				
				if value.to_s==@defaults[m].to_s
					manip.set_enabled false
					value=@defaults[m]
				else
					manip.set_enabled true
				end
				
				manip.set_data value
				manip.visible=true
				manip.show
			else
				manip.visible=false
				manip.hide
				manip.recalc
			end
		}
		EventEditor.instance.set_widget self
	end
	def reset_default prop_manip
		value=@defaults[prop_manip.method]
		prop_manip.set_data( value)
		
		update_wdg prop_manip
	end
	
	#a property has been changed. update widget
	def update_wdg prop_manip
		value=prop_manip.get_data
		m=prop_manip.method
		begin
			send(m, value)
		rescue Exception
			puts "error setting property: #{m}, value: #{value}"
			puts $!
			puts $!.backtrace
		end
		recalc
		shell.forceRefresh
		set_dirty
	end
	def set_name name
		PropMan.instance.nameProp.set_data name
		PropMan.instance.nameProp.wdg=self
	end
	def set_dirty
		self.userData.manager.set_dirty
	end
	#serializes all properties into this hash
	def serialize hash
		@defaults.each{|m, default|
			manip=PropMan.instance.props[m]
			value=send( m.chop)
			hash[m]=manip.serialize(value)
		}
	end
	#loads all properties from the hash
	def deserialize hash
		hash.each{|method, value|
			manip=PropMan.instance.props[method]
			unless manip 
				puts "no property object for #{method}!!"
				next
			end
			dvalue=manip.deserialize( value)
			#~ if ["icon=", "altIcon="].member?( method)
				#~ PropMan.instance.init_icons self
				#~ PropMan.instance.icons[self][method]=value
			#~ end			
			begin
				send(method, dvalue) if respond_to? method
			rescue Exception
				puts "#{method}: invalid value, #{$!}"
				puts $!.backtrace
			end
			recalc
			shell.forceRefresh
		}
	end
end # module Properties



class Fox::FXWindow
	include Properties
end
