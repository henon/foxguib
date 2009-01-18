# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)
#foxGUIb debug 

#TODO:
# add a libGUIb version
# scrollbar style
# terminate called after throwing an instance of 'FX::FXFontException'

# combobox and list and others: add Array-like interface 

# eliminate globals. $app --> App.instance
# replace pp with yaml
# show if document is modified
# codegenerator that outputs true subclasses as opposed to a delegator, or outputs module that can be included 
# review container. change container header to checker with boxstyle
# replace png dummy by tga dummy
# review img= (concerning the removal of icons)
# listitems, treeitems
# extract more docu from the fxruby api

#more TODOs:


# Also, I noticed that the code gen dialog does not automatically add  .rb to my chosen class name

# generator: floatinput.rb:99: uninitialized constant MainWindow (NameError)

# removing eventhandling code leaves a single character undeletable
# codegen derive instead of embed
# 'autosave ruby class' option
# 'generate code on every save' option.
#+namespace solution would be nice.
# convert old fox-tool examples to foxguib
# schow modified and ask to save

$DEBUG=true

require "foxGUIb"
