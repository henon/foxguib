# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "fxruby"
require "__FX__"
#include Fox


widgets=Fox.constants.find_all{|c| 
	begin
		c.to_s =~ /^FX/ and Object.const_get(c).ancestors.include? FXWindow
	rescue
		#puts "!"+c
	end
}
puts "Found #{widgets.size} Fox Widgets."
puts
widgets.sort.each{|wclass|
	have=FX.constants.include?( wclass.gsub(/^FX/,""))
	print "<code>" if have
	print "#{wclass}"
	print "</code>" if have
	puts "<br>"
}


