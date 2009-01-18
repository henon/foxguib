# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)
require "singleton"
require 'document'
require "genruby"
class DocMan 
  include Singleton
	def initialize 
		@docs=[]
		@doc_hash={}
		@parent=MAINWIN.topwin
		#@new_project_dlg.topwin.hide
		@genruby_dlg=GenRubyDialog.new @parent
		create_docman
		update
	end
	attr_reader :current, :docs, :doc_hash
	def ask_save
		# TODO
	end
	def genruby
		#puts "genruby_dlg"
		@genruby_dlg.show
	end
	def set_wdir
		dirdlg=FXDirDialog.new @parent, 'select the working directory'
		if dirdlg.execute==1
			wdir=dirdlg.directory.gsub(/\\/,'/')
			Dir.chdir wdir
			puts 'changed working dir to: '+wdir
		end
	end
	def add_widget classname, where="after"
		@current.add_widget( classname, where) if @current
	end
	def create doctype
		#~ @current.dlg.hide if @current
		#@current.topwin.hide if @current
		doc=Document.new doctype
		@docs << doc
		doc.name="unnamed_"+doctype+".rbin"
		tab=create_tab(doc)
		switch_documents(nil, nil, tab.index)
		update
		doc.topwin.resize(500, 400)
	end
	def close_all
		#TODO: ask save
		@docs.each{|doc|
			close( doc, true, false)
		}
	end
	def close( doc=@current, save=true, update_gui=true)
		return unless doc
		#TODO: ask save if @current.dirty and save==true
		doc.doclist_item.hide
		@tabbar.recalc
		@tabbar.forceRefresh
		doc.doclist_item.destroy # tabitem removed
		doc.topwin.destroy # dialog removed
		MAINWIN.Switcher.children[doc.switcherIndex].destroy # treelist removed
		@docs.delete doc # document removed
		if update_gui
			@current=@docs[@docs.size-1]
			switch
			update
		end
	end
	def switch
		if @current
			MAINWIN.Switcher.current=@current.switcherIndex
		else
			#MAINWIN.Switcher.current=0
			# ???
		end
		return unless @current and @current.marked
		#@genruby_dlg.topwin.hide
		@genruby_dlg.show if @genruby_dlg.topwin.shown? # update genruby dlg
		@current.marked.update_properties 
		EventEditor.instance.set_widget( @current.marked)
	end
	def switch_documents(*args)
		index=args[2]
		if index.kind_of? Integer
			tabitem=@tabbar.children[index]
			e=@doc_hash[tabitem]
			@current.topwin.hide if @current
			e.topwin.show(0)
			@current=e
			#event_document_switched @current
		end
		switch
	end
	def load
		filename=SuperFileDialog.new( @parent, '', 'load foxGUIb document').start
		if filename
			#~ @current.dlg.hide if @current
			#@current.topwin.hide if @current
			doc=Document.new nil
			doc.load filename
			@docs << doc
			#~ @list.appendItem filename
			#~ @current.doclist_item=@list.numItems-1
			tab=create_tab( doc)
			switch_documents nil, nil, tab.index
		end
		update
	end
	def save
		return unless @current
		@current.save @current.name
	end
	def save_as
		return unless @current
		filename= SuperFileDialog.new( @parent, @current.name, 'save foxGUIb document').start
		return unless filename
		@current.save filename 
		@current.doclist_item.text=filename
		@current.name=filename
	end
	def save_all
		@docs.each{|doc|
			doc.save doc.name
		}
	end
	def emergency_save
		@docs.each{|doc|
			doc.save doc.name+"_failsave.rbin"
		}
	end
	def generate opts, classname, unittest
		if opts=="ruby.class"
			dlg=RubyFileDialog.new @parent, @current.name, 'save generated ruby code'
			filename=dlg.start
			return unless filename
			$fxapp.beginWaitCursor{
				s=@current.generate_code opts, @current.fxtree.currentItem, classname, unittest
				f=File.new(filename, 'w')
				f.puts s
				f.close
			}
		end
	end
	def generate_code opts, item, classname=nil, unittest=true 
		return unless @current
		#rd,wr=IO.pipe
		s=@current.generate_code opts, item, classname, unittest
		#wr.flush
		#wr.close
		return s #rd.read
	end
	def set_dirty e
		item=e.doclist_item
		return unless item
		item.text+=" *"
	end
	def create_docman 
		@tabbar=MAINWIN.project_TabBar
		@tabbar.connect SEL_COMMAND, method(:switch_documents)
	end
	def update
		MAINWIN.genruby.enabled=(not @docs.empty?)
		MAINWIN.save_dialog.enabled=(not @docs.empty?)
		MAINWIN.save_dialog_as.enabled=(not @docs.empty?)
		MAINWIN.close_dialog.enabled=(not @docs.empty?)
		MAINWIN.viewDialog.enabled=(not @docs.empty?)
		#MAINWIN.hideDialog.enabled=(not @docs.empty?)
		if @docs.empty? and PropMan.created?
			PropMan.instance.reset_props
		end
		if @current
			@tabbar.setCurrent( @tabbar.children.index(@current.doclist_item))
		end
		@current.topwin.shown=true if @current
	end
	def create_tab doc
		tab=@tabbar.create_tab(doc.name)
		tab.backColor=STD_BACK_COLOR
		tab.frameStyle=FRAME_LINE
		tab.hiliteColor=FXRGB(0,0,0)
		tab.create
		doc.doclist_item=tab # todo: eliminate doclist_item!
		@doc_hash[tab]=doc
		return tab
	end
end

class SuperFileDialog
	def initialize p, filename='',title="no title"
		@dialog = FXFileDialog.new(p, title)
		@dialog.directory=Dir.getwd
		generate_patterns
		@dialog.patternList = @patterns
		@dialog.currentPattern = @currentPattern
		@dialog.filename=filename.to_s
	end
	
	def generate_patterns
		@patterns = ["All Files (*)",
			"Fox-GUIb Documents (*.pp,*.rbin)",
			"PrettyPrint Documents (*.pp)",
			"Binary Documents (*.rbin)"]
		@currentPattern=1
	end
	def start
		if @dialog.execute != 0
			return rel_path( Dir.getwd, @dialog.filename)
		end
		return nil
	end
end

class RubyFileDialog < SuperFileDialog
	def generate_patterns
		@patterns = ["All Files (*)",
			"Ruby Source Files (*.rb,*.rbw)"]
		@currentPattern=1
	end
end

class IconDialog < SuperFileDialog
	def generate_patterns
		@patterns = ["All Files (*)",
			"Images (*.gif,*.bmp,*.xpm,*.pcx,*.ico,*.png,*.jpg,*.tif,*.tga)",
			"GIF Image (*.gif)",
			"BMP Image (*.bmp)",
			"XPM Image (*.xpm)",
			"PCX Image (*.pcx)",
			"ICO Image (*.ico)",
			"PNG Image (*.png)",
			"JPEG Image (*.jpg)",
			"TIFF Image (*.tif)",
			"TARGA Image (*.tga)"
		]
		@currentPattern=1
	end
end

if __FILE__==$0
	puts rel_path( "F:/hilo/djdk/df", "F:/hilo/djdk/df\\fgdfg")
	puts rel_path( "F:/hilo/djdk/df", "F:/hilo/asdf")
end