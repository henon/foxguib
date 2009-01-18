# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "pp"

$cfg = {}

def load_settings filename
	begin
		$cfg = eval File.new( filename, "r").read()
	rescue Exception
		$cfg = {}
	ensure
		$cfg={} unless $cfg
	end
	# go to last working directory
	Dir.chdir $cfg[:wdir] if $cfg[:wdir] and File.exist? $cfg[:wdir]
end

def save_settings filename
	#memorize working directory
	$cfg[:wdir] = Dir.getwd
	
	Dir.chdir( HOME)
	$stdout=File.new filename, "w"
	puts "# foxGUIb configuration - edit carefully!"
	pp $cfg
end