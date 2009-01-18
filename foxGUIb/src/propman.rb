# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)
require "singleton"
require "prop-lists"
include FX
require 'prop-types'
#require 'container'
class PropMan
  include Singleton
  @@created=false
	def initialize
		@props={}
	end
  def PropMan.created?
    @@created
  end
	attr_accessor :type_lbl
	#widget name manipulator
	attr_reader :nameProp, :props, :icons
	
	def refresh
		#~ @sh.recalc
		#~ @sh.forceRefresh
	end
	def make_container(p, title)
		c=Container.new(p)
		c.title=title
		c.header.backColor=HEADER_COLOR
		c
	end
	def create width
    @@created=true
		v=p=MAINWIN.prop_Frame
		v.vSpacing=2
		v.packingHints=PACK_UNIFORM_WIDTH
		Label.new(v){|l| 
			@type_lbl=l 
			l.text=" "
		}
		@nameProp=NameProp.new( v)
		i=make_container v, "Flags"
		add_prop_manipulators $const_props, i
		i=make_container v, "General"
		add_prop_manipulators $general_props, i
		i=make_container v, "Color Properties"
		add_prop_manipulators $color_props, i
		$font_dlg=Fox::FXFontDialog.new p, 'Font Selection Dialog'
		$color_dlg=Fox::FXColorDialog.new p, 'Color Selection Dialog'
		p.recursive{|w|
			w.baseColor=STD_BACK_COLOR
			next if w.kind_of? TextField
			next if w.backColor==HEADER_COLOR
			w.backColor=STD_BACK_COLOR
		}
	end
  
	#creates all the propmanipulators and adds them to the parent p
	def add_prop_manipulators list, p
		list.each{|method, type, array|
			#~ next unless respond_to? method
			begin
				c=Object.const_get(type)
				@props[method]=c.new( p, method, array)
			rescue
				puts "type #{type}:"
				puts $!
				puts $!.backtrace.join( "\n")
				next
			end
		}
	end
	
	def reset_props
		#puts "reset_props"
		@type_lbl.text=" "
		@nameProp.set_data ""
		@props.each{|m,manip|
			manip.wdg=nil
			manip.set_enabled( false)
			manip.visible=true
			manip.show
			manip.forceRefresh
		}
		MAINWIN.prop_Frame.recalc
	end
end
