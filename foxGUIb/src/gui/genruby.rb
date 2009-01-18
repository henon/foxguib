# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "_guib_genruby"
class GenRubyDialog
	def init
		@topwin.hide
		@rg_startpoint=FX::RadioGroup.new
		@rg_startpoint.on_event_selected{|radio| update }
		@rg_startpoint << @topmost
		@rg_startpoint << @selected
		@rg_source=FX::RadioGroup.new
		@plain.wdg_name="plain"
		@to_class.wdg_name="class"
		@rg_source << @plain
		@rg_source << @to_class
		@rg_source.on_event_selected{|radio| @format=radio.wdg_name; update }
		@to_console.connect(Fox::SEL_COMMAND) { 
			$console.text.text=""
			$console.out( generate)
			$console.topwin.show(0)
		}
		@fs=FileSelector.new( @Packer)
		@fs.patterns << "Ruby Script (*.rb)"
		@fs.currentPattern=1
		@fs.description=""
		FlatStyle.new.apply_to( @fs.topwin)
		@fs.topwin.padTop=5
		@fs.topwin.layoutHints=Fox::LAYOUT_FILL_X
		@fs.topwin.padLeft=8
		@fs.topwin.padRight=8
		@fs.browse.text="..."
		@fs.textfield.connect(Fox::SEL_CHANGED){update}
		@fs.onNewFilenameBlock=Proc.new{update}
		@cancel.connect(Fox::SEL_COMMAND) {
			hide
		}
		@OK.connect(Fox::SEL_COMMAND) { 
			begin
				File.open(@fs.textfield.text, "wb"){|f|
					f.puts generate
				}
				@topwin.hide
			rescue Exception
				puts $! #TODO write msg to the dialog!!
				puts $!.backtrace
			end
		}
		@locked.connect(Fox::SEL_COMMAND, method( :update_locked))
		
		initialize_fields
		@topwin.resize(350, 350)
	end
	def update_locked(*args)
		for w in [@plain, @topmost, @selected, @to_class, @fs.textfield, @fs.browse, @className]
			#~ puts w.class
			w.enabled=!@locked.checked?
		end
	end	
	#saves the dialog state in a hash
	def to_h
		h={}
		h[:classname]=@fs.textfield.text
		h[:filename]=@className.text
		h[:to_class]=@to_class.state
		h[:plain]=@plain.state
		h[:topmost]=@topmost.state
		h[:selected]=@selected.state
		h[:locked]=@locked.state
		return h
	end
	def from_h h
		return unless h
		@fs.textfield.text=h[:classname] if h[:classname]
		@className.text=h[:filename] if h[:filename]
		@rg_source.select( @to_class) if h[:to_class]
		@rg_source.select( @plain.state) if h[:plain]
		@rg_startpoint.select(@topmost.state) if h[:topmost]
		@rg_startpoint.select(@selected) if h[:selected]
		@locked.state=h[:locked] if h[:locked]
	end
	def initialize_fields
		@locked.check=false
		@format="class"
		@plain.check=false
		@to_class.check=true
		@topmost.check=true
		@selected.check=false
		@className.text=""
		@fs.textfield.text=""
	end
	def update
		update_locked
		if @selected.state
			@item=DocMan.instance.current.fxtree.currentItem
		else
			@item=DocMan.instance.current.topwin.userData.treeitem
		end
		name=DocMan.instance.current.make_class_name @item
		@node.text=name
		@className.text=capitalize(@item.to_s) unless @locked.state
		#can only write if a filename is given:
		@OK.enabled=(@fs.textfield.text.size>0)
		#save state to the document
		DocMan.instance.current.gendlg_state=to_h
	end
	def show
		initialize_fields
		unless DocMan.instance.current
			puts "no document found."
			return
		end
		from_h DocMan.instance.current.gendlg_state
		#@item=DocMan.instance.current.topwin.userData.treeitem
		update
		@topwin.show(PLACEMENT_SCREEN)
	end
	def hide
		DocMan.instance.current.gendlg_state=to_h
		@topwin.hide
	end
	def generate
		#puts "generate"
		DocMan.instance.current.gendlg_state=to_h
		s=""
		begin
			s=DocMan.instance.generate_code "ruby.#{@format}", @item, capitalize(@className.text), true
		rescue Exception
			s=$!.to_s+"\n\t"+$!.backtrace.join("\n\t")
		end
		#puts "generated source:",s
		return s
	end
end

if __FILE__==$0
	Dir.chdir '..'
	$:<<"gui"
	require "libGUIb14"
	app=FX::App.new
	w=GenRubyDialog.new app
	w.topwin.show(0)
	app.create
	app.run
end