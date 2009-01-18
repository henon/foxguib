$: << ".."
require "fxruby"
require "fx"
require "minitest"
require "yaml"
require "widget-lists"


class TestDialog
	def initialize( parent)
		construct_widget_tree( parent)
	end
	
	def construct_widget_tree( parent)
		@topwin=
		FX::MainWindow.new(parent){|w|
			@DialogBox=w
			w.width=200
			w.shown=true
			w.y=325
			w.height=150
			w.x=540
		}
	end
	attr_accessor :topwin, :DialogBox

	def test_all_widgets
		ALL_WIDGETS.each{|name|
			test( "testing #{name}") {
				w=FX.const_get(name).new(@topwin)
				w.create
				yield w
				true
			}
		}	
	end

end


#unit test
if __FILE__==$0
	app=FX::App.new
	dlg=TestDialog.new app
	app.create
	dlg.test_all_widgets{|w|
		next unless w.respond_to? :text
		#w.text="hello world!"
		#puts  "#{w.font}, #{w.font.class}"
		#assert w.font.kind_of? FX
		#puts w.text.inspect
	}
#	dlg.topwin.show(0)
#	app.run
end
