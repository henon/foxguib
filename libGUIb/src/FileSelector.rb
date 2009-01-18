# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "_guib_FileSelector"

class FileSelector
	def init
		@title="File Dialog"
		@relative_path=false
		@filename=""
		
		@directory=Dir.getwd
		@dialog = Fox::FXFileDialog.new(@topwin, @title)
		@patterns = ["All Files (*)"]
		@currentPattern=0		
		@browse.connect(Fox::SEL_COMMAND, method( :onBrowse))
	end
	attr_accessor :directory, :patterns, :currentPattern, :title, :filename, :relative_path
	attr_accessor :onNewFilenameBlock
	def description=text
		@label.text=text
	end
	def description
		@label.text
	end
	def onBrowse(*args)
		@dialog.title=@title
		@dialog.directory=@directory
		@dialog.patternList = @patterns
		@currentPattern=0 if @currentPattern >= @patterns.size
		@dialog.currentPattern= @currentPattern
		@dialog.filename=filename.to_s
		if @dialog.execute != 0
			if @relative_path
				@filename=@textfield.text=rel_path( Dir.getwd, @dialog.filename)
			else
				@filename=@textfield.text=@dialog.filename
			end
			@onNewFilenameBlock.call if @onNewFilenameBlock.respond_to? "call"
		end
	end
end