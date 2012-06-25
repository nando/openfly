require 'rubygems'
require 'nokogiri'
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
    puts %!    <option value="#{pid}">#{pname}</option>!
    source = File.open("#{basedir}/#{filename}")
    doc = Nokogiri::XML(source)
    placemarks = doc.xpath('//Placemark')
    placemark = placemarks.last
    placemarks[0..-2].each {|p| p.remove}
    placemark.elements.detect{|e| e.name == 'name'}.content = pname
    
    doc.xpath('//Folder/name').first.content = "#{pname} Track"
    description = doc.xpath('//Folder/description').first
    description.parent = placemark
    doc.xpath('//Document').first.add_child <<-STYLE
  <Style id="track">
    <LineStyle>
      <color>bb#{sprintf("%06x", pid.to_i*41000)}</color>
      <gx:physicalWidth>1</gx:physicalWidth>
    </LineStyle>
  </Style>
  STYLE
    placemark.add_child <<-STYLE_REF
      <styleUrl>#track</styleUrl>
      STYLE_REF
    source.close
    File.open("#{destdir}/#{pid}.kml", 'w') {|f| f.write(doc.to_xml) }
  end
end