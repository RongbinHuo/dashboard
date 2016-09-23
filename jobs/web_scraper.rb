require 'open-uri'
require 'nokogiri'




url = 'http://www.cubecinema.com/programme'
html = open(url)
doc = Nokogiri::HTML(html)
