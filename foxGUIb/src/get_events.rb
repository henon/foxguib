# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

require "net/http"
require "uri"
$stdout.sync=true

require "widget-lists"
require "serialize"

LINK_REGEX=/(?m)(<a (?:.(?!<|>))*.>(?:.(?!<\/a>))*.<\/a>)/
LINK_SPLIT=LINK_REGEX #/(#{LINK_REGEX})/

def scan_text html, substitutions=nil
	unless substitutions
		substitutions={
			/<br>|<p>/=>"\n",
			/<table/=>"\n---:\n<table",
			/<tr/=>"<tr",
			/<\/tr/=>" \n</tr",
			/<td/=>" <td",
			/&nbsp;/=>" ",
			/&#8217;/=>"'",
		}
	end
	s=html.split.join(" ")
	substitutions.each{|re, ss|
		s.gsub!(re, ss)
	}
	s.scan( /(?m)>((?:(?=(?!<|>)).)+)</).flatten
end

def scan_tags html
	html.scan( /<(?:.(?!<|>))*.>/)
end

def scan_strings html
	html.scan /(["'])((?:(?!\1).)*)\1/ 
end


def scan_links html
	html.scan( LINK_REGEX).flatten
end

def split_links html
	html.split( LINK_REGEX)
end

include Serialize

File.open("events_docu.yaml", "wb"){|f|
	Net::HTTP.start("www.fxruby.org",80){|http|
		f.puts "---"
		ALL_WIDGETS.each{|name|
			response = http.get("/doc/api/classes/Fox/FX#{name}.html")
			f.puts "FX::#{name}:"
			a=scan_text(response.body).join.scan( /^\s*SEL_.+/)
			a.collect{|line| 
				parts=line.split(/:/)
				event=parts.shift
				description="!str #{parts.join(':')}"
				f.puts "  #{event}: #{description}"
				
			}
		}
	}
}
pp load_yaml( "events_docu.yaml")
