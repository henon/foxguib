# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

module MiddleBtn
	def handleMMB_Events
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONPRESS,   0, :onMiddleBtnPress)
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONRELEASE, 0, :onMiddleBtnRelease)
	end
	def onMiddleBtnPress(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self, MKUINT(selector, Fox::SEL_MIDDLEBUTTONPRESS), evt) != 0)
				return 1
			end
		end
		return 0
	end
	def onMiddleBtnRelease(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self,MKUINT(selector, Fox::SEL_MIDDLEBUTTONRELEASE), evt) != 0)
				return 1
			end
		end
		return 0
	end
end
module RightBtn
	def handleRMB_Events
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONPRESS,   0, :onMiddleBtnPress)
		FXMAPFUNC(Fox::SEL_MIDDLEBUTTONRELEASE, 0, :onMiddleBtnRelease)
	end
	def onRightBtnPress(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self, MKUINT(selector, Fox::SEL_RIGHTBUTTONPRESS), evt) != 0)
				return 1
			end
		end
		return 0
	end
	def onRightBtnRelease(sender, sel, evt)
		if enabled?
			if (target != nil)&&(target.handle(self,MKUINT(selector, Fox::SEL_RIGHTBUTTONRELEASE), evt) != 0)
				return 1
			end
		end
		return 0
	end
end
