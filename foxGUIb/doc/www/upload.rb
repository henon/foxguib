STDOUT.sync=true

puts %x( scp index.html fox-tool.rubyforge.org:/var/www/gforge-projects/fox-tool )

pw=File.read( "pw")
io = IO.popen("scp index.html fox-tool.rubyforge.org:/var/www/gforge-projects/fox-tool", "w")
puts "sleeping for a minute"
sleep 60
io.puts pw
