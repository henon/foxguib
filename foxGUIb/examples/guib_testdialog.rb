class TestDialog
	def initialize( parent)
		construct_widget_tree( parent)
		init if respond_to? 'init'
	end
	
	def construct_widget_tree( parent)
		@topwin=
		FX::DialogBox.new(parent){|w|
			@DialogBox=w
			w.width=200
			w.shown=true
			w.y=325
			w.height=150
			w.x=540
		}
	end
	attr_accessor :topwin,
	:DialogBox,
	:__foxGUIb__last__
end

#unit test
if __FILE__==$0
	require 'FX'
	app=App.new
	w=TestDialog.new app
	w.topwin.show(0)
	app.create
	app.run
end
