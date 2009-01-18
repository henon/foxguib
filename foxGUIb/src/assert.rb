# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

def assert(*args)
	args.each_with_index{|x,i|
		m="assertion: parameter #{i} is nil"
		raise m unless x
	}
end