# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

module RelinkMechanisms
	def RelinkMechanisms.relink_possible?( source, where, target)
		#general
		return false if source.nil? or target.nil?
		return false if source==target
		return false if target.childOf? source
		return insert_possible?( where, target)
	end
	def RelinkMechanisms.insert_possible? where, target
		raise TypeError unless where.kind_of? String and target.kind_of? Fox::FXWindow
		return false if where=='inside'and !target.composite?
		return false if where=='before'and target.kind_of? Fox::FXTopWindow
		return false if where=='after'and target.kind_of? Fox::FXTopWindow
		return true
	end	
	def RelinkMechanisms.relink_wdg source, where, target
		return unless relink_possible?(  source, where, target)
		if where=='before'
			#puts "link #{source} before #{target}"
			source.reparent target.parent, target if source.parent!=target.parent
			source.linkBefore target
		elsif where=='after'
			#puts "link #{source} after #{target}"
			source.reparent target.parent, target.next if source.parent!=target.parent
			source.linkAfter target
		elsif where=='inside'
			#puts "reparent #{source} under #{target}"
			source.reparent target, target.children.last
			source.linkAfter target.children.last
		else return
		end
		source.shell.forceRefresh
	end
	def RelinkMechanisms.mouse_relink( source, target)
		#puts "mouse_relink [#{source}] -> [#{target}]"
		if target.composite?
			relink_wdg source, "inside", target
		else
			if source.next==target
				relink_wdg source, "after", target
			else
				relink_wdg source, "before", target
			end
		end
	end
	def RelinkMechanisms.mouse_relink_test( source, target)
		if target.composite?
			return relink_possible?( source, "inside", target)
		else
			if source.next==target
				return relink_possible?( source, "after", target)
			else
				return relink_possible?( source, "before", target)
			end
		end
		return false
	end
	def RelinkMechanisms.keyboard_relink source, event
		return unless source
		target=where=nil
		if source
			if [CURSOR_UP,CURSOR_LEFT].include? event.code 
				where="before"
				target=source.prev
				unless $CTRL
					if target 
						where="inside" if target.composite?
					else
						target=source.parent
					end
				end
			elsif [CURSOR_DOWN,CURSOR_RIGHT].include? event.code 
				where="after" 
				target=source.next
				unless $CTRL
					if target 
						if target.children.size>0
							where="before"
							target=target.children[0]
						else
							where="inside" if target.composite?
						end
					else
						target=source.parent
					end
				end
			end
		end
		RelinkMechanisms.relink_wdg(source, where, target)
	end
end