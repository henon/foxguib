# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)


class StateMachine
	def initialize
		@states=[]
		@state_transitions={}
	end
	# first state is initial state
	def add_states( *states)
		@states|=states
	end
	def state_transition(state1, state2, condition, action=nil)
		array=@state_transitions.fetch(state1){ @state_transitions[state1]=[] }
		array << [state2, condition, action]
	end
	def start
		@__state__=@states[0]
	end
	def input data
		old_state=@__state__
		old_state.input=data
		a=@state_transitions[old_state]
		return unless a
		a.each{|record|
			new_state, condition, action = record
			if condition.call( old_state, new_state)
				@__state__=new_state
				action.call( old_state, new_state) if action
				break
			end
		}
	end
	def state
		return @__state__
	end
end

class State
	attr_accessor :input
	def initialize name
		@name=name
		@data={}
	end
	def []=( k, v)
		@data[k]=v
	end
	def []( k)
		return @data[k]
	end
	def to_s
		return @name.to_s
	end
end

if __FILE__==$0
	sm=StateMachine.new
	sm.add_states :UNSELECTED, :SELECTED
	condition=Proc.new{ true }
	action=Proc.new{|o,n| puts "#{o}-->#{n}"}
	sm.state_transition :UNSELECTED, :SELECTED, condition, action
	sm.state_transition :SELECTED, :UNSELECTED, condition, action
	sm.start
	sm.input nil
	sm.input nil
end