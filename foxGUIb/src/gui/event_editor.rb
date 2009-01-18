# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

if __FILE__==$0
	$: << "gui" 
	Dir.chdir ".."
	STDOUT.sync=true
	HOME="."
  require 'libGUIb16'
end
require "_guib_event_editor"
require "serialize"
require "singleton"
require "textview"

SELECTED_EVENT_COLOR=Fox::FXRGB(255,255,255)
UNSELECTED_EVENT_COLOR=Fox::FXRGB(200,200,200)

	
class EventEditor < GuibEventEditor
	include Singleton
	include Serialize
	def initialize
		super( MAINWIN.topwin)
		@widget=nil # the widget we are going to edit events for
		@eventGroup=FX::RadioGroup.new
		@eventsframe.layoutHints=Fox::LAYOUT_FIX_WIDTH|Fox::LAYOUT_FILL_Y
		@eventsframe.width=240
		init_event_list
		build_event_list
		@eventGroup.on_event_selected{|radio|
			@widget.set_behaviour( @selectedEvent, @Text.text) if @widget
			@selectedEvent=radio.text
			update
		}
		@CheckButton.connect(Fox::SEL_COMMAND){ update }
    @CheckButton.state=false
		@Text.connect(Fox::SEL_CHANGED){
			next unless( @widget and @selectedEvent)
			@widget.set_behaviour( @selectedEvent, @Text.text)
		}
		@TextView=TextView.new(@topwin)
		@TextView.topwin.hide
		@TextView.topwin.resize(400,200)
		update
	end
	
	def init_event_list
		@events={}
		loader=YamlLoader.new(HOME)
		loader.on_fail{|filename, msg| 
			puts "Warning: Event editor couldnt load data! - Error loading <#{filename}>: \n\t#{msg}"
		}
		loader.load("src/events.yaml"){|events| 
			events.each{|name|
				begin
					@events[name]=Fox.const_get(name)
				rescue Exception
					puts "cannot instantiate constant #{name}"
				end
			}
		}
		loader.load("src/events_docu.yaml"){|docu| @docu=docu }
	end
	
	def build_event_list
		@radioButtons={}
		@events.keys.sort.each{|name|
			FX::HorizontalFrame.new(@eventList){|h|
				h.wdg_name=name
				h.layoutHints=Fox::LAYOUT_FILL_X
				h.backColor=UNSELECTED_EVENT_COLOR
				FX::RadioButton.new(h){|r|
					r.text=name
					@radioButtons[name]=r
					r.backColor=UNSELECTED_EVENT_COLOR
					@eventGroup << r
				}
				next unless @docu
				FX::Button.new(h){|b|
					b.layoutHints=Fox::LAYOUT_RIGHT
					b.backColor=UNSELECTED_EVENT_COLOR
					b.text=" ? "
					b.connect(Fox::SEL_COMMAND){
						next unless @widget
						@TextView.heading.text="#{@widget.class.to_s}: #{name}"
						@TextView.Text.text="#{@docu[@widget.class.to_s][name]}\n\nExtracted from www.fxruby.org - Copyright by Lyle Johnson"
						@TextView.topwin.create if $app.created?
						@TextView.topwin.show(Fox::PLACEMENT_SCREEN)
					}
					b.visible=( @widget and @docu[@widget.class.to_s] and @docu[@widget.class.to_s].has_key?(name))
				}
			}
		}
	end
	
	def update
		unless @widget
			@Text.text="No widget is selected!"
			@Text.disable
			return 
		end
		@editframeLabel.text="@#{@widget.wdg_name}.connect(#{@selectedEvent}){"
		@evframeLabel.text="#{@widget.class}:"
		on=@CheckButton.state
		@eventList.children.each{|h|
			event=h.wdg_name
			next unless h.kind_of? FX::HorizontalFrame and event
			documented=(@widget and @docu[@widget.class.to_s] and @docu[@widget.class.to_s].has_key?( event))
			h.visible=( on or documented)
			h.children[1].visible=documented
			c=(@widget.get_behaviour( event).strip.empty? ? UNSELECTED_EVENT_COLOR : SELECTED_EVENT_COLOR)
			h.backColor=c
			h.children.each{|w| w.backColor=c }
		}
		@eventList.recalc
		if @selectedEvent
			@Text.text=@widget.get_behaviour( @selectedEvent).to_s
			@Text.enable
		else
			@Text.text="No event is selected!"
			@Text.disable
			@CheckButton.setFocus
		end
		@Text.setFocus
	end
	
	def set_widget w
		@widget=w
		update
	end

	def show
		w=@topwin
		w.create
		w.resize(800,500)
		w.show(Fox::PLACEMENT_VISIBLE)
	end
end

module Behaviour
	def set_behaviour event, code
		return unless event
		return if code.strip.empty?
		@behaviour||={}
		@behaviour[event]=code
	end
	def get_behaviour event
		return "" unless @behaviour
		return @behaviour[event].to_s
	end
	def behaviour
		return @behaviour
	end
	def behaviour= b
		@behaviour=b
	end
end

class Fox::FXWindow
	include Behaviour
end


#unit test
if __FILE__==$0
	app=FX::App.new
	MAINWIN=Class.new
  def MAINWIN.topwin
    @topwin
  end
  MAINWIN.instance_variable_set :@topwin, FX::MainWindow.new(app)
	w=EventEditor.instance
	w.topwin.show(0)
	w.set_widget w.CheckButton
	app.create
	app.run
end