# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "relink_mechanisms"

module WidgettreeControls
	#copy/paste clipboard
	$clipboard=[]

	def onClick wdg
		item=wdg.userData.treeitem
		if item.nil?
			error "this widget's item is nil",wdg.to_s
			return
		end
		@fxtree.currentItem=item
		expand_parents item
		mark wdg
		wdg.update_properties
		#~ @updateBrowserButtons.call item
		#~ unless $mvdestLbl.nil?
			#~ $mvdest=item
			#~ $mvdestLbl.text=item.to_s 
			#~ $mvdestLbl.shell.forceRefresh
		#~ end
	end
	
	def create_dlg
		@fxtree=TreeList.new( MAINWIN.Switcher, TREELIST_BROWSESELECT|TREELIST_SHOWS_LINES|TREELIST_SHOWS_BOXES)
		@fxtree.backColor=STD_BACK_COLOR
		@fxtree.create
		@switcherIndex=MAINWIN.Switcher.numChildren-1
		@root=@fxtree.appendItem nil, "root"
		@fxtree.connect( SEL_COMMAND, method( :item_click))
		@wdgMenu=WidgetMenu.new( MAINWIN.topwin)
		$__popup__=@wdgMenu if $DEBUG
		@wdgMenu.on_cmd_cut{|wdg|
			@wdgMenu.send :cmd_copy
			@wdgMenu.send :cmd_delete
		}
		@wdgMenu.on_cmd_copy{
			#~ puts "copy"
			wdg=@w[ @fxtree.currentItem.to_s]
			widgetlist=[]
			traverse( wdg, widgetlist)
			$clipboard << widgetlist
		}
		@wdgMenu.on_cmd_paste{|where|
			#~ puts "paste #{where}"
			wdg=@w[ @fxtree.currentItem.to_s]
			widgetlist=$clipboard.last
			load_widgettree( widgetlist, where, wdg)
		}
		@wdgMenu.on_cmd_jumpup{
			#~ puts "jumpup"
			item=@fxtree.currentItem
			relink_wdg item, 'before', item.prev unless item.prev.nil? or item.prev==@root
		}
		@wdgMenu.on_cmd_jumpdown{
			#~ puts "jumpdown"
			item=@fxtree.currentItem
			relink_wdg item, 'after', item.next unless item.next.nil?
		}
		@wdgMenu.on_cmd_delete{ 
			#~ puts "delete"
			unmark
			item=@fxtree.currentItem
			wdg=@w[item.to_s]
			wdg.parent.removeChild wdg
			@w.delete(item.to_s)
			#@marked=nil
			@fxtree.removeItem( item)
			# updating:
			item=@fxtree.currentItem
			wdg=@w[item.to_s]
			wdg.update_properties
		}
		@wdgMenu.on_cmd_events{
			EventEditor.instance.show
		}
		@fxtree.connect(SEL_RIGHTBUTTONPRESS) { |sender, sel, e|
			item = @fxtree.getCursorItem
			if item
				@fxtree.currentItem=item
			else
				item=@fxtree.currentItem
			end
			#item.setFocus(false)
			next if item == @root
			widget=@w[item.to_s]
			onClick widget
			@wdgMenu.popup_over( widget, e.rootclick_x, e.rootclick_y)
			#1
		}
	end
	class WidgetMenu
		__sends__ :cmd_jumpup, 
			:cmd_jumpdown, 
			:cmd_cut, 
			:cmd_copy, 
			:cmd_paste,
			:cmd_delete,
			:cmd_events
			
		def initialize parent
			@popup=FXPopup.new parent
			@title=FXMenuCaption.new @popup, '@popup_title'
			FXMenuSeparator.new @popup
			cmd "events", "Edit events ..."
			cmd "---"
			cmd 'jumpup', "Jump up"
			cmd 'jumpdown', "Jump down"
			cmd "---"
			cmd 'cut', "Cut"
			cmd 'copy', "Copy"
			["before", "after", "inside"].each{|where|
				instance_eval %{
					def self.cmd_paste_#{where}(*args)
						cmd_paste "#{where}"
					end
				}
				cmd "paste_#{where}", "Paste #{where}"
			}
			cmd "delete", "Delete"
			cmd "---"
			cmd "cancel", "Cancel"
			@popup.create if $fxapp.created?
		end
		def popup_over widget, x, y
			#paste concerns: is it possible to paste before, after or inside this widget?
			["before", "after", "inside"].each{|where|
				cmd=instance_variable_get( "@mc_paste_#{where}")
				cmd.enabled=RelinkMechanisms.insert_possible?( where, widget)
				cmd.enabled=false if $clipboard.nil? or $clipboard.empty?
			}
			@mc_jumpup.enabled=!widget.prev.nil?
			@mc_jumpdown.enabled=!widget.next.nil?
			[@mc_cut, @mc_delete, @mc_copy].each{|mc| mc.enabled=true }
			[@mc_cut, @mc_delete, @mc_copy, @mc_jumpup, @mc_jumpdown].each{|mc|
				mc.enabled=false if widget.kind_of?( Fox::FXTopWindow)
			}
			@title.text="[ #{widget.class} ]"
			@popup.popup nil, x, y
		end
	private
		def cmd name, text=nil
			if name=="---"
				MenuSeparator.new( @popup )
			else
				text=name unless text
				MenuCommand.new( @popup){|c|
					instance_variable_set "@mc_#{name}", c
					c.text=text
					c.connect(SEL_COMMAND) {
						m="cmd_#{name}"
						send m
					}
				}
			end
		end
		def method_missing(*args)
			puts "WidgetMenu#method missing: #{args.inspect}" if $DEBUG
		end
	end

	def item_click(*args)
		item=args[2]
		return if item==@root
		unless $mvdestLbl.nil?
			$mvdest=item
			$mvdestLbl.text=item.to_s 
			$mvdestLbl.shell.forceRefresh
		end
		wdg = @w[item.to_s]
		mark wdg if wdg
		wdg.update_properties
		#~ @updateBrowserButtons.call item
	end
end #module
