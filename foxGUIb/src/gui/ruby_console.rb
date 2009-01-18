# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require 'libGUIb16' if __FILE__==$0
require "guib__console"

class Console < BaseConsole

	def initialize( parent)
		super
		create_styles
		@cmdln.connect(SEL_COMMAND){
			execute
		}
		@history=["",""]
		@histpos=0
		#@back.connect(SEL_COMMAND){ gohistory( -1) }
		#@fwd.connect(SEL_COMMAND){ gohistory( 1) }
		#@text.text="use out(*args) to print expressions to the console\n"
		#~ @HistoryText.textStyle-=TEXT_READONLY
		@text.textStyle-=TEXT_WORDWRAP
		@CmdsText.textStyle-=TEXT_WORDWRAP
		@HistoryText.textStyle-=TEXT_WORDWRAP
		#~ @text.connect(SEL_KEYPRESS) {|x,y,evt|
			#~ if evt.code > 0 and evt.code <= 255
				#~ @text.text+=evt.code.chr
			#~ else
				#~ 0
			#~ end
		#~ }
		#load_cmds
		@cmdln.connect(SEL_KEYPRESS) {|x,y,evt|
			if evt.code==65362
				gohistory( -1)
				1
			elsif evt.code==65364
				gohistory( 1) 
				1
			#TODO: PgUp and PgDown to scroll the @text.text
			else
				0
			end
		}
		@HorizontalFrame5.hide
		configure_textbuffer @HistoryText
		configure_textbuffer @CmdsText
		@cmdln.setFocus
		@scrolling=true
	end
	attr_reader :s_error, :s_op, :s_cmd
	def create_styles
		@text.styled=true
		
		# syntax hiliting styles:
		@styles=[
			@s_error = FXHiliteStyle.new,
			@s_cmd = FXHiliteStyle.new,
			@s_op = FXHiliteStyle.new,
		]
		@styles.each{|style|
			style.normalForeColor = @text.textColor
			style.normalBackColor = @text.backColor
			style.selectForeColor = @text.selTextColor
			style.selectBackColor = @text.selBackColor
			style.hiliteForeColor = @text.hiliteTextColor
			style.hiliteBackColor = @text.hiliteBackColor
			style.activeBackColor = @text.activeBackColor
			style.style = 0
		}
		
		# ruby syntax error
		@s_error.normalForeColor = FXRGB(228,128,130)
		
		# recognized d1 command
		@s_cmd.normalForeColor = FXRGB(50,80,234)

		# console operator outputs
		@s_op.normalForeColor = FXRGB(104,152,113)
		
		@text.hiliteStyles=@styles
	end
	
	def load_cmds filename
		require filename
		@cmds=[]
		$cmds.each{|a|
			cmd=a[0]
			@cmds << cmd
			params=a[1]
			help=a[2]
			@CmdsText.appendText "#{cmd} #{params}\n"
		}
	end
	
	def configure_textbuffer buffer
		buffer.connect(SEL_LEFTBUTTONRELEASE){
			if buffer.selEndPos==buffer.selStartPos
				a=buffer.lineStart( buffer.cursorPos)
				e=buffer.lineEnd( buffer.cursorPos)
				seltext=buffer.text[a..e]
				@cmdln.text=seltext.chomp
			end
			0
		}
		buffer.connect(SEL_SELECTED){|x,y,data|
			seltext=buffer.text[data[0]..data[0]+data[1]]
			@cmdln.text=seltext.chomp
		}
		buffer.connect(SEL_KEYPRESS){|x,y,data|
			out data.code
			if data.code==65293
				execute
			end
			0
		}
	end

	def gohistory go
		@histpos+=go
		@histpos=0 if @histpos < 0
		@histpos=@history.size-1 if @histpos >= @history.size
		@cmdln.text=@history[@histpos]
	end
	
	def addhistory cmd
		@history.pop # poppin empty string
		last=@history.pop
		@history << last
		if cmd != last
			@history << cmd.chomp 
			@HistoryText.text+=cmd.chomp+"\n"
		end
		@history << ""
		@histpos=@history.size-1
	end
	
	def execute cmd=nil
		unless cmd
			cmd=@cmdln.text
		end
		begin
			addhistory cmd
			
			out ">", cmd.split($/).join($/+"> ")
			
			@rv=eval cmd
		rescue Exception
			#@cmdln.textColor=FXRGB(255,0,0)
			styled_out( @s_error, "\t", $!)
			styled_out( @s_error,  "\t", $!.backtrace.join($/+"\t"))
		end
		@cmdln.text=""
		@cmdln.setFocus
	end
	def prepare_args(*args)
		args.collect! {|e| 
			if e.nil?
				'<nil>'
			elsif e.kind_of? Array 
				e.join(' ')
			else
				e
			end
		}
		s=args.join( ' ')
		return s
	end
	def print_to_console(s, line_ending="")
		unless @text.nil?
			@text.appendText s+line_ending
			# scroll to the end
			@text.makePositionVisible( @text.text.size) if @scrolling
			#puts s
		end
	end
	# every argument is converted to string and joined with delimiter ' '
	# arguments that are nil will be printed as "<nil>" instead of printing nil.to_s
	# out with no arguments will print a "\n" to the console
	def p(*args)
		s=prepare_args(*args)
		print_to_console( s)
		return s
	end
	def out(*args)
		s=prepare_args(*args)
		print_to_console( s, $/)
		return s
	end
	def styled_print_to_console(s, style, line_ending="")
		unless @text.nil?
			pos=@text.text.size
			@text.appendText s+line_ending
			# style it !!!
			@text.changeStyle( pos, s.size, get_style_index(style))		
			# scroll to the end
			@text.makePositionVisible( @text.text.size) if @scrolling
			#puts s
		end
	end
	def styled_out(style, *args)
		s=prepare_args(*args)
		styled_print_to_console( s, style, $/)
	end
	def styled_p(style, *args)
		s=prepare_args(*args)
		styled_print_to_console( s, style)
	end
	def get_style_index(style)
		return @styles.index(style)+1
	end
	def noscroll
		@scrolling=false
	end
	def scroll
		@scrolling=true
	end
	def nolang
		@MenuButton.text="Menu"
		@HistoryTabItem.text="History"
		@CmdsTabItem.text="Commands"
		@Label4.text="Cmd >"
		@Label5.text="Address:"
	end	
end
#~ def out(*args)
	#~ $console.out(*args)
#~ end

def create_console
	$app=App.new
	$console=Console.new $app
	$console.topwin.show(0)
	$app.create
end

def create_console_nolang
	$app=App.new 
	$console=Console.new $app
	$console.nolang
	$console.topwin.show(0)
	$app.create	
end




def run_console
	$app.run
end
#unit test

if __FILE__==$0
	#Dir.chdir ".."
	#require "paths"
	$FX="FX/"
	create_console_nolang
	run_console
end

