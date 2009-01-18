# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

# spag/hettizer:
# packs everything into one executable ruby script
STDOUT.sync=true

$program_src_dir="./"
$program_release_dir="../" 
$program_file="__FX__.rb"
$output_file="lib/libGUIb16.rb"
$zip=false

$DEBUG=false

$debugstring='"##{$program_working_dir}/#{filename}:#{i}:  "'

$exclusion_names=[ # won't be inserted
	/paths/, 
	/fox(\/)?/, 
	/etc\.so/,
	/properties/,
	/code-gen/,
	/^FX/,
	/fxruby/,
]
$force_require=[ # files that are not implicitely required can be forced to be "included" here
	#"FileSelector-extension",
	"PathSelector-extension",
]
$required_files=[] # will be required bevore generation of the release script
$files_to_be_copied=[ # will be copied to release dir; $V marks directory
]
$require_paths=["","FX",
]

$path_replacements={
#	"pp"=>ENV["RUBY_HOME"]+"/..todo../pp"
}

# ####################################

def prepare
	Dir.chdir( $program_src_dir)
	$required_files.each{|file|
		require file
	}

	$required_files=[]
end

def winPath(path)
	path.gsub(/\//, "\\")
end

def check_exclusions filename
	$exclusion_names.each{|regex|
		if filename =~ regex
			puts "#### excluded: #{filename}"
			return true 
		end
	}
	return false
end

$inside_unittest_block=false

def check_exist filename
	if File.exists?( filename)
		return filename
	else
		$require_paths.each{|path|
			newname=File.join path, filename
			return newname if File.exists? newname
		}
		raise "! File not found: "+filename
	end
end

# simulates require
def fill_in f, require_string
	filename=eval(require_string)
	return unless filename
	filename+=".rb" unless filename =~ /(\.rb$)|(\.rbw$)/
	if check_exclusions(filename)
		f.print "###### excluded: \n"  if $DEBUG
		f.print "require "+ require_string,"\n"
		return
	end
	f.print "# require "+filename,"\n" if $DEBUG
	puts "REQUIRE-STRING: #{require_string}"
	filename=check_exist( filename)
	return if $required_files.member? filename
	puts "\tFILENAME: #{filename}"
	$required_files << filename
	f1=File.open( filename, "r")	
	i=0
	for line in f1.readlines
		i+=1
		if $inside_unittest_block and line.strip =~ /end/ 
			$inside_unittest_block=false 
			next
		end
		break if line =~ /#\s*MAKE_CUTOFF/
		next if line.strip =~ /#\s*MAKE_DROP/
		next if $inside_unittest_block
		next if line.strip.empty?
		next if line.strip =~ /^#/
		next if line.strip =~ /^;/
		next if line.strip =~ /^dbg/			
		next if line.strip =~ /^assert/			
		if line.strip =~ /^if __FILE__/
			$inside_unittest_block=true 
			next
		end
		next if line.strip =~ /\sif __FILE__/
		unless line =~ /require(\s|\().*((".*")|('.*'))/
			f.print line.chomp, "\n"
			f.print eval($debugstring), "\n" if $DEBUG and line.strip =~ /end/
			next
		end
		require_string=line.strip.gsub(/require/, "")
		fill_in f, require_string
	end
end

def make_dir dir
	begin
		Dir.mkdir dir
	rescue Exception
		puts "mkdir: "+$!
	end
end

def delete_release
	cmd="rd /s /q #{winPath($program_release_dir)}"
	puts "> "+cmd
	puts "> "+%x( #{cmd})
	make_dir( $release_dir)
end

def copy file
	isdir = (file =~ /\$V/ )
	if isdir
		file.gsub!( /\$V/, "")
		cmd="xcopy /I /R #{winPath(file)} #{winPath($program_release_dir+File.basename(file))}"
	else
		cmd="copy #{winPath(file)} #{winPath($program_release_dir+File.basename(file))}"
	end
	puts "> "+cmd
	puts "\t"+ %x(#{cmd})
end

def zippe
	f=File.open($program_release_dir + $gz_output_file, "wb")
	g=File.open($program_release_dir + $output_file, "rb")
	f.write( Zlib::Deflate.deflate(g.read(), Zlib::BEST_COMPRESSION))
	f.close
	g.close
end

#delete_release
#make_dir $program_release_dir

puts "###### generating #{$output_file}:"
# klartext output file
File.open( $program_release_dir + $output_file, "wb"){|g|
	g.puts '# libGUIb: Copyright (c) by Meinrad Recheis aka Henon, 2006'
	g.puts '# THIS SOFTWARE IS PROVIDED IN THE HOPE THAT IT WILL BE USEFUL'
	g.puts '# WITHOUT ANY IMPLIED WARRANTY OR FITNESS FOR ANY PURPOSE.'
	prepare
	#input
	#~ File.open( $program_file, "r"){|f|
		#make it
		fill_in g, "'#{$program_file}'"
		$force_require.each{|name| fill_in g, "'#{name}'"}
#		File.open("../build/included_files.rb", "w"){|h|
#			h.puts $required_files.inspect.split.join("\n")
#		}
		puts "###### copying files"
		$files_to_be_copied.each{|fname|
			copy(fname)
		}
	#~ }
}
if $zip
	require "zlib"
	zippe
end

# installing:
Dir.chdir $program_release_dir
if PLATFORM=~/win32/
  %x(ruby install.rb)
else
  pw=File.read( "pw")
  io = IO.popen("sudo -S ruby install.rb", "w")
  sleep 1
  io.puts pw
end