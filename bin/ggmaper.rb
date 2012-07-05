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
html = File.open("#{destdir}.html", 'w')
task_name = destdir.split('_').map{|w|w.capitalize}.join(' ')
html.write(<<HTML_HEADER)
---
  layout: viewer
  title: Tracks #{task_name}
---

<script type="text/javascript">
  var tracks_base = 'http://clubdevuelopb.com/open/tracks/2012/#{destdir}/',
      pilots = {
HTML_HEADER
kolor_factor = (16777215.0 / Dir.new(basedir).entries.map{|e| (e =~ /(.*?)\..*\.(\d*)\.kml/i ? $2 : 0).to_i}.max).to_i
contains = Dir.new(basedir).entries.each do |filename|
  if filename =~ /(.*?)\..*\.(\d*)\.kml/i
    pname, pid = $1, $2
    html.write %!       #{pid}: "#{pname}",\n!
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
      <color>ee#{sprintf("%06x", pid.to_i*kolor_factor)}</color>
      <width>2</width>
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
html.write(<<HTML_FOOTER)
      },
      pilot_1 = ,
      pilot_2 = ,
      pilot_3 = ;

      function kml_color(pilot_id) {
        var color = sprintf("%06x", parseInt(pilot_id) * #{kolor_factor});
        return('#' + color.substr(4,2) + color.substr(2,2) + color.substr(0,2));
      }
</script>
HTML_FOOTER
html.close
