# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

class PathSelector
	def initialize( parent)
		construct_widget_tree( parent)
		init if respond_to? 'init'
	end
	
	def construct_widget_tree( parent)
		@topwin=
		FX::HorizontalFrame.new(parent){|w|
			@PathSelector=w
			w.padLeft=0
			w.frameStyle=0
			w.padRight=0
			w.hSpacing=2
			w.height=21
			w.layoutHints=1024
			FX::Label.new(@PathSelector){|w|
				@label=w
				w.text="Path:"
				w.width=30
				w.x=0
			}
			FX::TextField.new(@PathSelector){|w|
				@textfield=w
				w.width=291
				w.y=0
				w.layoutHints=1024
				w.x=32
			}
			FX::Button.new(@PathSelector){|w|
				@browse=w
				w.text="Browse..."
				w.padLeft=4
				w.width=59
				w.padRight=4
				w.y=0
				w.x=325
			}
		}
	end
	attr_accessor :topwin,
	:PathSelector,
	:label,
	:textfield,
	:browse,
	:__foxGUIb__last__
end
s='PathSelector-extension.rb'
require s if File.exist?(s)
#unit test
if __FILE__==$0
	Dir.chdir ".."
	require 'FX'
	app=App.new
	mw=MainWindow.new app
	w=PathSelector.new mw
	mw.show(0)
	app.create
	app.run
end
