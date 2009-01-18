# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

def rel_path(a, b)
	raise TypeError unless (a.kind_of? String and b.kind_of? String)
	a.gsub!(/\\/,'/')
	b.gsub!(/\\/,'/')
	a = a.split('/')
	b = b.split('/')
	i = 0
	while ((a[i] == b[i]) && (i < a.size))
	i += 1
	end
	'../'*(a.size - i) + b[i..-1].join('/')
end