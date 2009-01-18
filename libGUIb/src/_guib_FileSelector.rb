class FileSelector
	def initialize( parent)
		construct_widget_tree( parent)
		init if respond_to? 'init'
	end
	
	def construct_widget_tree( parent)
		@topwin=
		FX::HorizontalFrame.new(parent){|w|
			@FileSelector=w
			w.padLeft=0
			w.frameStyle=0
			w.padRight=0
			w.hSpacing=2
			w.height=21
			w.layoutHints=1024
			FX::Label.new(@FileSelector){|w|
				@label=w
				w.text="File:"
				w.width=24
				w.x=0
			}
			FX::TextField.new(@FileSelector){|w|
				@textfield=w
				w.width=297
				w.y=0
				w.layoutHints=1024
				w.x=26
			}
			FX::Button.new(@FileSelector){|w|
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
	:FileSelector,
	:label,
	:textfield,
	:browse,
	:__foxGUIb__last__
end
#~ s='FileSelector-extension.rb'
#~ require s if File.exist?(s)
#unit test
if __FILE__==$0
	Dir.chdir ".."
	require 'FX'
	app=App.new
	mw=MainWindow.new app
	w=FileSelector.new mw
	mw.show(0)
	app.create
	app.run
end
