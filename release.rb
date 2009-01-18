STDOUT.sync=true

puts %x( svn stat )

#~ Dir.chdir "foxGUIb"
#~ require "foxGUIb" # after checking that it runs and everything is ok, the foxGUIb gets closed and we get hiere:
#~ Dir.chdir ".."
require "foxGUIb/src/version"

release_dir="#{FOXGUIB_NAME}_#{FOXGUIB_VERSION}"
puts %x( svn export -rHEAD svn+ssh://rubyforge.org/var/svn/fox-tool #{release_dir} )
puts %x( rm -v #{release_dir}/release.rb )

#~ puts File.read( "#{release_dir}/foxGUIb/log.txt")
puts %x( rm -v #{release_dir}/foxGUIb/guib.conf )
puts %x( rm -v #{release_dir}/foxGUIb/log.txt )

#create archives
puts %x( zip -r #{release_dir}.zip #{release_dir} )
puts %x( tar -cvvzf #{release_dir}.tar.gz #{release_dir} )

puts %x( md5sum #{release_dir}.zip )
puts %x( md5sum #{release_dir}.tar.gz )