require 'fileutils.rb'
include FileUtils

unless ARGV[0] and ARGV[1]
  puts("Uso: ruby ggmaper.rb fuente destino")
  exit
end

basedir = ARGV[0]
destdir = ARGV[1]

mkdir(destdir) rescue nil

contains = Dir.new(basedir).entries.each do |filename|
  if filename =~ /(.*?)\..*\.(\d*)\.kml/i
    pname, pid = $1, $2
    cp "#{basedir}/#{filename}", "#{destdir}/#{pid}.kml"  
    puts %!    <option value="#{pid}">#{pname}</option>!
  end
end
