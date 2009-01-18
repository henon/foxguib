# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "relative-path"
class PathSelector
	def init
		@title="Directory Dialog"
		@relative_path=false
		@directory=Dir.getwd
		update(@directory)
		@dialog = FXDirDialog.new(@topwin, @title)
		@browse.connect(SEL_COMMAND, method( :onBrowse))
	end
	attr_accessor  :directory, :title, :filename, :relative_path
	def description=text
		@label.text=text
	end
	def description
		@label.text
	end	
	def onBrowse(*args)
		@dialog.title=@title
		@dialog.directory=@directory
		if @dialog.execute != 0
			update(@dialog.directory)
		end
	end
	def update(path)
		if @relative_path
			@directory=@textfield.text=rel_path( Dir.getwd, path)
		else
			@directory=@textfield.text=path
		end
	end
end