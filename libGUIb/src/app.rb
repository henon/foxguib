# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

module FX
class App < Fox::FXApp
	def initialize a="",b=""
		super
		@created=false
		$app=$fxapp=self
		#$fxtooltip=FXTooltip.new $fxapp
	end
	def create(*args)
		super
		@created=true
	end
	def created?()
		return @created
	end
end

end #FX

