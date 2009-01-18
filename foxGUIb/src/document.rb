# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "assert"
require "code-gen/code-generator"
require "serialize"
require "widgettree-controls"
require "relink_mechanisms"

MARKED_COLOR=Fox::FXRGB(1,150,250)

class UserData # TODO: to be ELIMINATED
	def initialize treeitem, manager
		raise "treeitem is nil" unless treeitem
		@treeitem=treeitem
		@manager=manager
	end
	attr_accessor :treeitem, :manager
end

class Document
	include CodeGenerator
	include Serialize
	include WidgettreeControls
	def initialize etype
		@switcherIndex=0
		create_dlg #@ WidgettreeControls.rb
		@w={}
		@names={}
		@implicit_children=true
		name=nil
		@type=etype
		init( etype) if etype
		@gendlg_state={}
	end

	attr_accessor :doclist_item
	attr_accessor :name
	attr_accessor :topwin, :type,
		:dlg, 
		:marked, 
		:marked_wcolor,
		:fxtree,
		:switcherIndex, #the switcher-index of the treelist for this Document
		:gendlg_state
	#~ attr_reader :w # breaks codegen
	
	def init etype
		@w[@root.to_s]=MAINWIN.topwin
		classname=name=""
		if etype=="mainwin"
			classname="#{DialogBox}"
			name="mainWindow"
		elsif etype=="dlg"
			classname="#{DialogBox}"
			name="dialogBox"
		elsif etype=="popup"
			# TODO:
		end
		if name 
			@topwin=add_widget classname, nil, @root
			rename_wdg(@topwin, name)
			@topwin.resize(500,400)
			@topwin.show(PLACEMENT_SCREEN)
		end
		if etype=="mainwin"
			def @topwin.class
				MainWindow
			end
		end
	end

	def load filename
		data=load_from_file( filename)
		@name=filename
		@names=data[:names] #to avoid inconsistencies while loading the widgettree
		@type=data[:type]
		@gendlg_state=data[:gendlg_state]
		init @type
		rename_wdg( @topwin, data[:hierarchy].first[:name])
		@topwin.set_name( data[:hierarchy].first[:name])
		@topwin.deserialize( data[:hierarchy].first[ :prop])
		load_widgettree data[:hierarchy].first[:sub], "inside", @topwin
		@names=data[:names] #to reset to the saved state
		@topwin.layout
		@fxtree.currentItem=@topwin.userData.treeitem
		@topwin.update_properties
		unmark; mark @topwin
	end
	#recursive loading function of a subtree. used by "load" and "paste".
	#	hashes: an array of hashes representing widgets that shall be created where(=inside/after/before the relativeWidget)
	def load_widgettree hashes, where, relativeWdg
		tmp=@implicit_children
		@implicit_children=false
		hashes.each{|hash|
			#hash[:name]=get_name(hash[:name]) if @w.has_key?( hash[:name])
			wdg=add_widget( hash[:cl], where, relativeWdg.userData.treeitem)
			unless wdg
				puts "add_widget returned nil for <#{hash[:name]}>!"
				next
			end
			wdg.deserialize hash[ :prop]
			wdg.behaviour=hash[:behaviour] if hash[:behaviour]
			load_widgettree hash[:sub], "inside", wdg
			rename_wdg( wdg, hash[:name])
		}
		@implicit_children=tmp
	end
	def save filename
		unmark
		data={
			:type=>@type,
			:names=>@names,
			:hierarchy=>[],
			:gendlg_state=>@gendlg_state
		}
		start_node=@root.below
		traverse(@topwin, data[:hierarchy])
		if filename
			$fxapp.beginWaitCursor
			save_to_file filename, data
			$fxapp.endWaitCursor
		else
			puts "no filename given. didn't save."
		end
		data
	end
	def traverse( widget, nodelist)
		return unless widget
		hash={}
		subnodes=[]
		hash[:sub]=subnodes
		nodelist << hash
		#wdg=@w[treenode.to_s]
		hash[:name]=widget.wdg_name #wdg.userData.treeitem.text
		hash[:cl]=widget.class.to_s.sub(/FX::/,'')
		prophash={}
		hash[:prop]=prophash
		widget.serialize prophash
		hash[:behaviour]=widget.behaviour
		widget.each_child{|child| 
			traverse( child, subnodes) if child.respond_to? :hilighted=
		}
		traverse( widget.menu, subnodes) if widget.respond_to? :menu
	end
	def add_widget classname, opts="after", currentitem=@fxtree.currentItem
		assert( currentitem)
		wdg=parent=parentitem=nil
		if currentitem.parent==@root and opts!="inside"
			# linking as subnode
			parent=@w[currentitem.to_s]
			parentitem=currentitem
			opts="inside"
		elsif opts=="after" or opts=="before" 
			parent=@w[currentitem.parent.to_s]
			parentitem=currentitem.parent
			siblingitem=currentitem
		elsif opts=="inside"
			parent=@w[currentitem.to_s]
			parentitem=currentitem
		elsif currentitem==@root
			parent=@w[currentitem.to_s]
			parentitem=currentitem
		end
		begin
			wdg=create_wdg( classname, parent)
			raise "error creating wdg" unless wdg
			wdg.wdg_name=name=add_reference( classname.downcase, wdg)
			currentitem=@fxtree.appendItem parentitem, name
			wdg.userData=UserData.new( currentitem, self)
			@fxtree.currentItem=currentitem
			if opts=="after" or opts=="before"
				currentitem=relink_wdg( currentitem, opts, siblingitem).userData.treeitem
			end
			create_implicit_children classname
			expand_parents currentitem
			@fxtree.forceRefresh
			set_dirty
			wdg.update_properties
		rescue
			puts $!
			puts $!.backtrace.join("\n")
		end
		wdg
	end
	def create_wdg classname, p
		wdg=nil
		assert( p)
		check_integrity classname, p
		wdg=eval(classname).new p
		m=wdg.method( :backColor)
		# cache real backColor so that marked widgets don't get confused with their markedColor and real backColor
		def wdg.backColor=c
			@backColor=c
			super unless @hilighted
		end
		def wdg.backColor
			@backColor
		end
		def wdg.hilighted=b
			@hilighted=b
			c = @hilighted ? MARKED_COLOR : @backColor
			setBackColor(c)
		end
		wdg.backColor=wdg.getBackColor
		wdg.enable
		wdg.connect(SEL_LEFTBUTTONPRESS) { onClick wdg; 0 }
		wdg.connect(SEL_RIGHTBUTTONPRESS) {|x,y,e|
			unmark; #mark wdg
			onClick wdg
			@wdgMenu.popup_over( wdg, e.rootclick_x, e.rootclick_y)
			0
		}
		wdg.create
		wdg.recalc
		wdg.shell.forceRefresh
		wdg.create_defaults
		unmark
		mark wdg
		wdg
	end
	def create_implicit_children parentclass
		return unless @implicit_children
		if ['Menubar'].member? parentclass
			add_widget "MenuTitle", "inside"
		elsif ['MenuTitle', 'MenuCascade','OptionMenu', 'MenuButton'].member? parentclass
			add_widget "MenuPane", "inside"
		elsif ['TabItem'].member? parentclass
			add_widget "VerticalFrame", "after"
		end
	end
	def rename_wdg wdg, newName
		return unless wdg
		begin
			nil.instance_eval( "@#{newName}") # check if newName is a suitable instance variable name
		rescue Exception
			puts $!
			puts $!.backtrace
			return
		end
		item=wdg.userData.treeitem
		return if item.nil?
		return if item==newName
		if @w.has_key? newName
			puts "<#{newName}> already exists!"
			return
		end
		oldName=item.to_s
		item.text=newName
		wdg.wdg_name=newName
		wdg.userData.treeitem=item
		@w[newName]=wdg
		@w.delete oldName if @w[oldName]==@w[newName]
		@fxtree.update
		return true
	end
	def check_integrity type, parent
		if type=="MenuPane" and not parent.respond_to?( 'menu=')
			raise "error: #{parent.class} cannot be parent to a MenuPane!" 
		elsif type=='MenuTitle' and not parent.kind_of? FXToolBar
			raise 'not allowed: behavior undefined!'
		elsif type=='MenuCascade' and not parent.kind_of? FXPopup
			raise 'not allowed: behavior undefined!' 
		elsif type=='TabItem' and not parent.kind_of? FXTabBar
			raise 'error: #{parent.class} cannot hold a TabItem!'
		end
	end
	# moves a widget in the browser and the gui
	def relink_wdg item, where, relativeItem
		assert( relativeItem, item, where)
		wdg=@w[item.to_s]
		parent=@w[relativeItem.parent.to_s]
		relativeWdg=@w[relativeItem.to_s]
		unless RelinkMechanisms.relink_possible?( wdg, where, relativeWdg)
			puts "relink of #{wdg} #{where} #{relativeWdg} is not possible" #TODO log4r!
			return
		end
		new=nil
		if where=='before'
			new=@fxtree.insertItem relativeItem, relativeItem.parent, FXTreeItem.new( item.to_s)
		elsif where=='after'
			if relativeItem.next
				new=@fxtree.insertItem relativeItem.next, relativeItem.parent, FXTreeItem.new( item.to_s)
			else
				new=@fxtree.appendItem relativeItem.parent, FXTreeItem.new( item.to_s)
			end
		elsif where=='inside'
			new=@fxtree.appendItem relativeItem, FXTreeItem.new( item.to_s)
		else return
		end
		expand_parents new
		@fxtree.currentItem=new
		a=[]; subitem=nil
		item.each{|subitem| a << subitem}
		a.each{|subitem|
			@fxtree.reparentItem subitem, new
		}
		RelinkMechanisms.relink_wdg wdg, where, relativeWdg		
		@fxtree.removeItem item
		wdg.userData.treeitem=new #TODO don't use userData. better a singleton instance var
		unmark
		mark wdg
		@fxtree.forceRefresh
		wdg.shell.forceRefresh
		set_dirty
		wdg
	end
	#used to add a newly instanciated widget to the hashmap @widgets which 
	#associates widget names to widget references
	#note: this method renames ambiguous names
	def add_reference name, wdg
		assert(wdg)
		name=get_name(name)
		@w[name]=wdg
		wdg.set_name name
		name
	end
	#makes shure a widget name is unique within the widgettree
	#applies a simple renaming scheme and returns the unique name
	def get_name(name)
		begin
			if @names.has_key? name
				@names[name] += 1
			else
				@names[name] = 1
			end
			postfix=''
			postfix=@names[name].to_s if @names[name] > 0
			wdg_name=name+postfix
		end while(@w.has_key?(wdg_name))   # check, that name is unique
		return wdg_name
	end
	#sets the document as modified, as to ask the user to save on exit
	def set_dirty
		unless @dirty
			@dirty=true
      DocMan.instance.set_dirty self
		end
	end
	def show	#????
		MAINWIN.topwin.show(Fox::PLACEMENT_SCREEN)
	end	
	# expands or collapses all subnodes of the item in the widget browser treelist
	def expand item, bool=true
		if bool
			@fxtree.expandTree item
		else
			@fxtree.collapseTree item
		end
		item.each{|sub|
			expand sub, bool
		}
	end
	# expands all parents for the item to be shown
	def expand_parents item
		assert item
		unless item.parent.nil?
			@fxtree.expandTree item.parent
			expand_parents item.parent
		end
	end
	# colorizes the background of the currently selected widget.
	# if marked allready the original color is restored
	def mark wdg
		return unless wdg
		if wdg==@marked
			wdg.hilighted=wdg.instance_eval{ not @hilighted }
		else
			unmark
			wdg.hilighted=true
			@marked = wdg
			$__wdg__= @marked # for console debugging
		end
	end
	# makes shure the current widget is not marked
	def unmark
		return unless @marked
		@marked.hilighted=false 
		@marked = nil
	end
end
