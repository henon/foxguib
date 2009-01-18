# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

#~ require 'FX'
require 'pp'

def load_from_file filename
	data=nil
	f=nil
	if filename.split('.').pop == 'pp'
		f=File.new(filename)
		#~ puts 'pp load'
		begin
			data = eval( f.read )
		rescue Exception
			error 'pp load error: ', $!.to_s
		end
	else
		f=File.new(filename, 'rb')
		#~ puts 'binary load'
		begin
			data = Marshal.load( f.read )
		rescue Exception
			error 'binary load error: ', $!.to_s
		end
	end
	f.close
	data
end	
def save data, filename
	if filename.split('.').pop == 'pp'
		begin
			out=$stdout
			$stdout=File.new( filename.gsub(/\\/,'/'), 'w')
			pp data
			$stdout.flush
		rescue Exception
			filename += '.rbin'
			puts 'rescue marshal to: '+filename
			puts $!
			puts $!.backtrace.join( $/)
			try_marshal = true
		ensure
			$stdout.close
			$stdout=out
		end
	else
		try_marshal = true
	end
	if try_marshal
		f=File.new( filename.gsub(/\\/,'/'), 'wb')
		Marshal.dump data, f
		f.flush
		f.close
	end
end

puts "converting #{ARGV[0]} to #{ARGV[1]}"
data=load_from_file ARGV[0]
save data, ARGV[1]