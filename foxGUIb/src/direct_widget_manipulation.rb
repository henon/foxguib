# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "libGUIb16"
require "fox16"
require "state_machine"
require "event_listener"
require "relink_mechanisms"

KEY_MODS={
	"SHIFT"=>1,
	"CAPSLOCK"=>2,
	"CTRL"=>4,
	"ALT"=>8,
	"NUM"=>16,
	"ROLL"=>224,
}
KEY_CODES={
	"CURSOR_UP"=>65362,
	"CURSOR_LEFT"=>65361,
	"CURSOR_DOWN"=>65364,
	"CURSOR_RIGHT"=>65363,
}
KEY_CODES.each{|k,v| eval "#{k}=#{v}" }
KEY_MODS.each{|k,v| eval "#{k}=#{v}" }

module DirectWidgetManipulation
	include Fox
	__sends__ "event_MOTION", "event_LEAVE", "event_ENTER", "event_LEFTBUTTONPRESS", "event_LEFTBUTTONRELEASE"
	__sends__ "event_KEYPRESS", "event_KEYRELEASE"
	attr_accessor :do_hover, :do_relink, :do_select
	$hovered_widgets=[]
	$selected_widgets=[]
	SELECT_COLOR=Fox::FXRGB(255,0,0)
	CURSOR_COLOR=Fox::FXRGB(255,0,0)
	HOVER_COLOR=Fox::FXRGB(100,120,255)
	FRAMESTYLE_METHODS={
		"hiliteColor"=>SELECT_COLOR,
		"shadowColor"=>SELECT_COLOR,
		"borderColor"=>SELECT_COLOR,
		"frameStyle"=>FRAME_LINE|FRAME_THICK,
	}
	HOVER_METHODS={
		"backColor"=>HOVER_COLOR,
	}
	def setup_drag_statemachine
		@do_hover=true
		@do_relink=true
		@do_select=true
		@drag_SM=StateMachine.new
		states=[
			idle=State.new("IDLE"), 
			lmbdown=State.new("LMBDOWN"), 
			dragging=State.new("DRAGGING"),
		]
		@drag_SM.add_states( *states)
		action=Proc.new{|o,n| #puts "#{o}-->#{n}"
		}
		@drag_SM.state_transition( idle, lmbdown, 
			Proc.new{|o, n| o.input["event_name"]==SEL_LEFTBUTTONPRESS }, 
			action
		)
		@drag_SM.state_transition( lmbdown, idle, 
			Proc.new{|o, n| o.input["event_name"]==SEL_LEFTBUTTONRELEASE }, 
			Proc.new{|o,n| #puts "#{o}-->#{n}"
				extended_select
			}
		)
		@drag_SM.state_transition( lmbdown, dragging, 
			Proc.new{|o, n| o.input["event_name"]==SEL_MOTION }, 
			a=Proc.new{|o,n| n[:last_time]=Time.now }
		)
		@drag_SM.state_transition( dragging, dragging, 
			Proc.new{|o, n|
				t=o[:last_time]
				o.input["event_name"]==SEL_MOTION and (Time.now.to_f-t.to_f)>0.1
			},
			Proc.new{|o,n| n[:last_time]=Time.now
				break unless @do_relink
				e=o.input["event"]
				dest=shell.get_widget_at(translateCoordinatesTo(shell, e.win_x, e.win_y))
				#p dest
				dest.hover if RelinkMechanisms.mouse_relink_test( self, dest) and dest.respond_to? :hover
			}
		)
		@drag_SM.state_transition( dragging, idle,
			Proc.new{|o, n| o.input["event_name"]==SEL_LEFTBUTTONRELEASE }, 
			Proc.new{|o,n| n[:last_time]=Time.now
				break unless @do_relink
				e=o.input["event"]
				dest=shell.get_widget_at(translateCoordinatesTo(shell, e.win_x, e.win_y))
				#p dest
				RelinkMechanisms.mouse_relink( self, dest)
			}
		)
		@drag_SM.start
	end
	def hover(*args)
		return if !@do_hover or @hovered
		@hovered=true
		$hovered_widgets.each{|w| w.unhover }
		$hovered_widgets<<self
		HOVER_METHODS.each{|method, value|
			eval "@_#{method}=self.#{method}" if self.respond_to? method
			eval "self.#{method}=#{value}" if self.respond_to? method+"="
		}
	end
	def unhover(*args)
		return if !@do_hover or !@hovered or @drag_SM.state.to_s=="DRAGGING"
		@hovered=false
		$hovered_widgets.delete self
		HOVER_METHODS.each{|method, value|
			eval "self.#{method}=@_#{method}" if self.respond_to? method+"="
		}
	end
	def deselect_all
		$selected_widgets.dup.each{|w| w.deselect }
	end
	def extended_select
		deselect_all unless $CTRL
		@selected ? deselect(:recursive=>true) : select(:recursive=>true)
	end
	def select(params={})
		return if !@do_select or @selected
		$selected_widgets << self
		@selected=true
		FRAMESTYLE_METHODS.each{|method, value|
			eval "@_#{method}=self.#{method}" if self.respond_to? method
			eval "self.#{method}=#{value}" if self.respond_to? method+"="
		}
		if $SHIFT and params[:recursive]
			children.each{|w| w.select(params) if w.respond_to? :select }
		end
	end
	def deselect(params={})
		return if !@do_select or !@selected
		$selected_widgets.delete self
		@selected=false
		FRAMESTYLE_METHODS.each{|method, value|
			eval "self.#{method}=@_#{method}" if self.respond_to? method+"="
		}
		if $SHIFT and params[:recursive]
			children.each{|w| w.deselect(params) if w.respond_to? :deselect }
		end
	end
	def edit_mode
		multiplex_mouse_events!
		observe_keymods!
		self.enabled=true
		setup_drag_statemachine
		@em_leave=on_event_LEAVE{|sender, selector, event| unhover }
		@em_motion=on_event_MOTION{|sender, selector, event|
			hover
			@drag_SM.input "event_name" => SEL_MOTION, "event" => event
		}
		@em_lbpress=on_event_LEFTBUTTONPRESS{|sender, selector, event|
			@drag_SM.input "event_name" => SEL_LEFTBUTTONPRESS, "event" => event
		}
		@em_lbrelease=on_event_LEFTBUTTONRELEASE{|sender, selector, event|
			@drag_SM.input "event_name" => SEL_LEFTBUTTONRELEASE, "event" => event
		}
		multiplex_keyboard_events!	
		@em_keypress=on_event_KEYPRESS{|sender, selector, event|
			RelinkMechanisms.keyboard_relink( $selected_widgets[0], event)
		}
	end
	def disable_edit_mode
		del_event_LEAVE @em_leave
		del_event_MOTION @em_motion
		del_event_LEFTBUTTONRELEASE @em_lbrelease
		del_event_LEFTBUTTONPRESS @em_lbpress
		del_event_KEYPRESS @em_keypress
		$hovered_widgets.each{|w| w.unhover }
		deselect_all
		@drag_SM=nil
	end
	def insert_mode
		self.enabled=true
		multiplex_mouse_events!
		observe_keymods!
		@im_keypress=on_event_KEYPRESS{|sender, selector, event|
			$insert_cursor.children[0].backColor=CURSOR_COLOR
			RelinkMechanisms.keyboard_relink( $insert_cursor, event)
			update_cursor
		}
		@im_lbpress=on_event_LEFTBUTTONPRESS{|sender, selector, event|
			$insert_cursor.children[0].backColor=CURSOR_COLOR
			RelinkMechanisms.mouse_relink $insert_cursor, self
			update_cursor
		}
		unless $insert_cursor
			$insert_cursor = Fox::FXPacker.new(shell)
			inside=Fox::FXFrame.new($insert_cursor)
			$insert_cursor.create if $fxapp.created?
			$insert_cursor.pad(2,2,2,2)
			inside.pad(1,1,1,1)
			inside.frameStyle=$insert_cursor.frameStyle=0
			timeout=proc {|sender, sel, data|
				if inside.backColor==CURSOR_COLOR
					inside.backColor=$insert_cursor.backColor
				else
					inside.backColor=CURSOR_COLOR
				end
				$cursor_timer=$fxapp.addTimeout(500, &timeout)
			}
			$cursor_timer=$fxapp.addTimeout(500, &timeout)
			update_cursor
		end
	end
	def disable_insert_mode
		del_event_LEFTBUTTONPRESS @im_lbpress
		del_event_KEYPRESS @im_keypress
		if $cursor_timer
			$fxapp.removeTimeout( $cursor_timer) 
			$cursor_timer=nil
		end
		if $insert_cursor
			p=$insert_cursor.parent
			$insert_cursor.destroy
			p.recalc
		end
		$insert_cursor=nil
	end
	def update_cursor
		if $insert_cursor.parent.kind_of? Fox::FXHorizontalFrame 
			$insert_cursor.children[0].layoutHints=$insert_cursor.layoutHints=LAYOUT_FILL_Y
		else
			$insert_cursor.children[0].layoutHints=$insert_cursor.layoutHints=LAYOUT_FILL_X
		end
		$insert_cursor.backColor=$insert_cursor.parent.backColor
	end
	#~ def deactivate_mode
		#~ # maybe there is a better way to "unconnect"?
		#~ connect(SEL_MOTION){0} 
		#~ connect(SEL_ENTER){0}
		#~ connect(SEL_LEAVE){0}
		#~ connect(SEL_LEFTBUTTONPRESS){0}
		#~ connect(SEL_LEFTBUTTONRELEASE){0}
		#~ connect(SEL_KEYPRESS){0}
		#~ connect(SEL_KEYRELEASE){0}
	#~ end
end
class Fox::FXWindow
	include DirectWidgetManipulation
	def get_widget_at pos
		#puts "-\t#{self.class}"
		child=self.getChildAt( *pos)
		if child.nil? 
			return self
		elsif child.composite?
			return child.get_widget_at( translateCoordinatesTo( child, pos[0], pos[1]))
		else 
			return child
		end
	end
	def multiplex_mouse_events!
		connect(SEL_LEAVE){|sender, selector, event| event_LEAVE(sender, selector, event); 0}
		connect(SEL_MOTION){|sender, selector, event| event_MOTION(sender, selector, event); 0}
		connect(SEL_LEFTBUTTONPRESS){|sender, selector, event| event_LEFTBUTTONPRESS(sender, selector, event); 0}
		connect(SEL_LEFTBUTTONRELEASE){|sender, selector, event| event_LEFTBUTTONRELEASE(sender, selector, event); 0}
	end
	def multiplex_keyboard_events!
		connect(SEL_KEYPRESS){|sender, selector, event| event_KEYPRESS(sender, selector, event); 1}
		connect(SEL_KEYRELEASE){|sender, selector, event| event_KEYRELEASE(sender, selector, event); 1}
	end
	#listen to keyboard modifiers such as CTRL, SHIFT, etc. 
	#and set flags: $CTRL, $SHIFT, etc
	def observe_keymods!
		multiplex_keyboard_events!
		on_event_KEYPRESS{|sender, selector, event|
			#puts event.state
			KEY_MODS.each{|mod,value|
				eval("$#{mod}=true if !$#{mod}") if event.state&value==value
			}
			#p [$CTRL, $SHIFT, $ALT]
		}
		on_event_KEYRELEASE{|sender, selector, event|
			KEY_MODS.each{|mod,value|
				eval("$#{mod}=nil if $#{mod}") if event.state&value==0
			}
		}
	end
end


if __FILE__==$0
	$stdout.sync=true
	include Fox
	#==================================
	app=FX::App.new "", ""
	mw=FX::MainWindow.new app
	mw.pad(10,10,10,10)
		lb=FX::Label.new mw
		hf=FX::HorizontalFrame.new mw, FRAME_LINE
			btn=FX::Button.new hf
			hf=FX::GroupBox.new hf
				btn=FX::Button.new hf
	mw.recursive{|w| 
			w.edit_mode
	}
	btn.connect(SEL_COMMAND){
		mw.recursive{|w|
			w.disable_edit_mode
			w.insert_mode
		}
	}
	btn.text="click to change to insert mode"
	mw.show
	mw.observe_keymods!
	app.create
	app.run
	#==================================
end