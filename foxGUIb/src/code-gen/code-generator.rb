# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

def capitalize name
	name[0]=name[0..0].capitalize[0]
	return name
end

module CodeGenerator

def generate_code opts, item=@fxtree.currentItem, classname=nil, unittest=true
	@wr = ""
	unmark
	w "# source generated by #{FOXGUIB}"
	w
	if opts=="ruby.plain"
 		gen_widget_tree "ruby", item
	elsif opts=="ruby.class"
		gen_class "ruby", item, classname, unittest
#	elsif opts=="ruby.derived_class"
		#~ gen_app "ruby"
	end
	return @wr
end

def i( text="")
	@indent=0 unless @indent
	@ws="\t" unless @ws
	#@wr=$stdout if @wr.nil?
	@wr+=( (@ws*@indent)+text)+$/
	@indent+=1
end

def w( text="")
	@indent=0 unless @indent
	@ws="\t" unless @ws
	#@wr=$stdout if @wr.nil?
	@wr+=( (@ws*@indent)+text)+$/
end

def o( text="")
	@indent=0 unless @indent
	@indent-=1
	@ws="\t" unless @ws
	#@wr=$stdout if @wr.nil?
	@wr+=( (@ws*@indent)+text)+$/
end

def gen_app lang
	if lang=="ruby"
		#TODO
	end
end
def make_class_name treeitem
	name=treeitem.to_s
	return capitalize( name)
end
def gen_class lang, treeitem, name=nil, unittest=true
	name=make_class_name treeitem unless name
	if lang=="ruby"
		i("class #{name}" )
			i("def initialize( parent)")
				w "construct_widget_tree( parent)"
				w "init if respond_to? 'init'"
			o( "end")
			w ""
			i("def construct_widget_tree( parent)")
				w "@topwin="
				gen_widget_tree lang, treeitem
			o "end"
			w "attr_reader :topwin"
			gen_accessors lang, treeitem
		o "end"
		w
		#w "s='#{name}-extension.rb'"
		#w "require s if File.exist?(s)"
		gen_unittest lang, treeitem, name
	end
end

def gen_widget_tree lang, treeitem, parent_name="parent"
	wdg=@w[treeitem.to_s]
	raise "widget #{treeitem} is nil! cannot generate code." unless wdg
	if lang=="ruby"
		i("#{wdg.class}.new(#{parent_name}){|w_#{treeitem}|")
			w "@#{treeitem}=w_#{treeitem}"
			w "w_#{treeitem}.wdg_name='#{treeitem}'"
			wdg.generate_properties {|p| w p.to( lang, treeitem) }
			generate_behaviour wdg, lang, treeitem
			treeitem.each{|child|
				gen_widget_tree lang, child, "@#{treeitem}"
			}
		o "}"
	end
end

def generate_behaviour wdg, lang, treeitem
	return unless wdg.behaviour
	wdg.behaviour.each{|event, code|
		next if code.strip.empty?
		i( "@#{treeitem}.connect(Fox::#{event}){")
			code.split($/).each{|line|
				w line
			}
		o( "}")
	}
end

def gen_accessors lang, treeitem
	if lang=="ruby"
		w "attr_reader :#{treeitem}"
		treeitem.each{|child|
			gen_accessors lang, child
		}
	end
end

def gen_unittest lang, treeitem, name
	if lang=="ruby"
		w "#unit test"
		i("if __FILE__==$0")
			w "require '#{FOXGUIB_LIBRARY}'"
			w "app=FX::App.new"
			if @w[treeitem.to_s]==@topwin
				w "w=#{name}.new app"
				w "w.topwin.show(Fox::PLACEMENT_SCREEN)"
			else
				w "mw=MainWindow.new app"
				w "w=#{name}.new mw"
				w "mw.show(Fox::PLACEMENT_SCREEN)"
			end
			w "app.create"
			w "app.run"
		o "end"
	end
end

#~ def gen_multiling_code lang, treeitem
	#~ name=treeitem.to_s
	#~ name[0]=name[0..0].capitalize[0]
	#~ if lang=="ruby"
		#~ i("module #{name}Texts" )
			#~ i("def #{treeitem.to_s.downcase}_texts")
				#~ gen_texts lang, treeitem
			#~ o"end"
		#~ o "end"
	#~ end
#~ end

#~ def gen_texts lang, treeitem
	#~ wdg=@w[treeitem.to_s]
	#~ wdg.defaults.keys.each{|m|
		#~ p=$propman.props[m]
		#~ next unless p.kind_of? StringProp
		#~ value=wdg.send m.chop
		#~ next unless value.to_s.size == 0
		#~ if lang=="ruby"
			#~ w "$L.register @#{treeitem.to_s}," if m=="text="
			#~ w "$L.register_method @#{treeitem.to_s}, '#{m}'," if m!="text="
			#~ i()
				#~ w "['de', '#{value.to_s}'],"
				#~ w "['en', ' ']"
			#~ o()
		#~ end
	#~ }
	#~ treeitem.each{|child|
		#~ gen_texts lang, child
	#~ }
#~ end

end # module CodeGenerator
