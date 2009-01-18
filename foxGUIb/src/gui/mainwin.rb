# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

# initialisation of the foxGUIb main window
require "_guib_mainwin"
require "event_editor"
require "textview"

class MainWin
	def init
		@topwin.title= "#{FOXGUIB} - Interactive FOX GUI Builder and Code Generator"
		@open_project.connect(SEL_COMMAND) {DocMan.instance.set_wdir}
		@new_mainwin.connect(SEL_COMMAND) {DocMan.instance.create "mainwin"}
		@new_dialog.connect(SEL_COMMAND) {DocMan.instance.create "dlg"}
		@open_dialog.connect(SEL_COMMAND) {DocMan.instance.load}
		@close_dialog.connect(SEL_COMMAND) {DocMan.instance.close}
		@save_dialog.connect(SEL_COMMAND) {DocMan.instance.save}
		@save_dialog_as.connect(SEL_COMMAND) {DocMan.instance.save_as}
		@genruby.connect(SEL_COMMAND) {
			DocMan.instance.genruby
		}
		@viewEventEditor.connect(SEL_COMMAND) {
			EventEditor.instance.show
		}
		@viewRubyConsole.connect(SEL_COMMAND) {
			$console.topwin.show(PLACEMENT_SCREEN)
		}
		@viewDialog.connect(SEL_COMMAND) {
			DocMan.instance.current.topwin.show(PLACEMENT_SCREEN)
		}
		#~ @hideDialog.connect(SEL_COMMAND) {
			#~ DocMan.instance.current.topwin.hide
		#~ }
		@about.connect(SEL_COMMAND) {about}
		@quit.connect(SEL_COMMAND) { exit }
		@topwin.connect(SEL_CLOSE) { exit }
	end
	
	def exit
		DocMan.instance.ask_save
		DocMan.instance.save_all
		$fxapp.exit	
	end

	def about
		#~ puts "about"
		#$console.topwin.show(0)
		tv=TextView.new(@topwin)
		tv.topwin.resize(600,400)
		tv.heading.text="About foxGUIb:"
		msg=[
			"Created by Henon, Copyright (c) 2004-2006, (mail: meinrad.recheis#gmail.com)",
			"License: \"Artistic License\". The source of foxGUIb including the libGUIb library may be changed and redistributed if the license and copyrights are kept.",
			"Any generated sources are free to use (commercial or noncommercial) but the author of foxGUIb does not take any responsibilities.",
			"",
			"Homepage: http://fox-tool.rubyforge.org",
			"Users Guide: http://www.mikeparr.info/rubyguib/foxguibhome.htm",
			"Rubyforge: http://rubyforge.org/projects/fox-tool/",
			"",
			"foxGUIb version: #{FOXGUIB_VERSION}",
			"\tFXRuby version: #{Fox.fxrubyversion}",
			"\tFOX version: #{Fox.fxversion}\n\n",
		]
		#$console.styled_out($console.s_cmd, msg.join("\n\t"))
		tv.Text.appendText msg.join("\n")
		Loader.new(HOME).load("license.rd"){|text|
			tv.Text.appendText(text)
		}
		tv.topwin.show
		tv.topwin.create
	end

end
