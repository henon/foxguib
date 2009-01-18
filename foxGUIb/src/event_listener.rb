# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

class Module
    def __sends__ *args
        args.each { |arg|
            class_eval <<-CEEND
                def on_#{arg}(&callback)
                    @#{arg}_observers ||= {}
                    @#{arg}_observers[caller[0]]=callback
		    return caller[0]
                end
		def del_#{arg}(id)
			@#{arg}_observers ||= {}
			return @#{arg}_observers.delete( id)
		end
                private
                def #{arg} *the_args
                    @#{arg}_observers ||= {}
                    @#{arg}_observers.each { |caller, cb|
                        cb.call *the_args
                    }
                end
            CEEND
        }
    end
end

if __FILE__==$0
	class TextBox
	    __sends__ "text_changed", "key_pressed"
	    
	    def initialize txt = ""
		@txt = txt
	    end
	    
	    def txt= txt
		@txt = txt
		text_changed
	    end
	    
	    def key_press key
		key_pressed key
	    end
	end
	
	box = TextBox::new
	text_changed_id=box.on_text_changed { puts "Text changed!" }
	5.times{|i|
		box.on_key_pressed { |k| puts "(#{i}) Key pressed: #{k}" }
	}
	
	box.txt= "New text!"
	box.del_text_changed( text_changed_id)
	box.txt= "New text!"
	
	box.key_press 'j'
end
