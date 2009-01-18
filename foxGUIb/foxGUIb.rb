# Copyright (c) 2004-2008 by Henon (meinrad dot recheis at gmail dot com)

# foxGUIb - main script
# when started with ruby's commandline option -d output goes to $stdout otherwise to log.txt

$:<<"src"<<"src/gui"<<"src/code-gen"
require "version"

begin
  require FOXGUIB_LIBRARY
rescue LoadError
  puts $!
  puts
  puts "Possible causes of this error are:"
  puts "* libGUIb is not installed"
  puts "* fxruby is not installed"
  puts "* fxruby gem could not be loaded because you did not start ruby with -rubygems option"
  puts "* other unexpected error. please check the following backtrace to find the cause of the error."
  puts
  puts $!.backtrace
  exit
end

STDOUT.sync=true
unless $DEBUG
  $stdout=File.new("log.txt", "a")
  $stdout.sync=true
end
puts "\nstarting foxGUIb #{FOXGUIB_VERSION}. #{Time.now}"
puts "\tRUBY VERSION #{VERSION}"
puts "\tPLATFORM #{PLATFORM}"

HOME=Dir.getwd

include FX
include Fox
puts "\tFXRuby version: #{Fox.fxrubyversion}"
puts "\tFOX version: #{Fox.fxversion}\n\n"

require "properties"
require "widget-generator"
require "mainwin"
require 'docman'
require 'propman'
require 'widget-selector'
require "ruby_console"
require "cfgman"

STD_BACK_COLOR=FXRGB(230,230,230)
HEADER_COLOR=FXRGB(255,255,168)

App.new FOXGUIB, ""
MAINWIN=MainWin.new $app
MAINWIN.topwin.shown=false
DocMan.instance
PropMan.instance.create( width=300)
WidgetSelector.instance
$console=Console.new( MAINWIN.topwin)
$console.nolang
$console.styled_out($console.s_op, "#{FOXGUIB} interactive ruby command console\nuse 'out(*args)' to output objects to the console.")
$console.topwin.hide
# --- 
$fxapp.create
MAINWIN.topwin.resize(1000,600)
MAINWIN.topwin.show(PLACEMENT_SCREEN)
begin
	load_settings("guib.conf")
	
	$fxapp.run
	puts 'exited normally'
rescue Exception
	puts '#'*15
	puts $!
	puts $!.backtrace.join("\n")
	puts '#'*15
	DocMan.instance.emergency_save
ensure
	save_settings("guib.conf")
end
