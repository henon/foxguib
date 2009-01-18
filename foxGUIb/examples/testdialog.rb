# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

 $stdout.sync=true
 require "guib_testdialog"
 class TestDialog
	def init
		#exits the interpreter when the dialog is closed
		@topwin.connect(SEL_CLOSE){
			puts "goodbye!"
			exit(0)
		}
		#adding a button here manually just to show 
		#that you can to just anything in the extension file
		Fox::FXButton.new(@topwin, "click me"){|b|
			b.connect(SEL_COMMAND){
				puts "hello world!"
			}
		}
	end
 end
 #unit test just copied from the guib file
 if __FILE__==$0
	require '../FX'
	app=App.new
	w=TestDialog.new app
	w.topwin.show(0)
	app.create
	app.run
 end
