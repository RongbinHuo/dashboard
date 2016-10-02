require 'mysql'
require 'open-uri'
require 'nokogiri'

db_host  = "rongbin.cdpxz2jepyxw.us-east-1.rds.amazonaws.com"
db_user  = "root"
db_pass  = "12345678"
db_name = "twit"

conn = Mysql.new(db_host, db_user, db_pass, db_name)
check_query = conn.prepare('SELECT * from gold_news where text = (?)')
insert = conn.prepare('INSERT INTO gold_news (text, link) VALUES(?, ?)')

url = 'http://www.usagold.com/dailyquotes.html'

SCHEDULER.every '600s' do
	html = open(url)
	doc = Nokogiri::HTML(html)

	news_time_source = doc.css('span.txtarial11 table tr td[valign="TOP"]')

	news_time_source.each do |n|
		if n["align"].nil?
			news_text = n.text.strip()
			href = n.css('font a')[0]['href'].strip()
			rs = check_query.execute(news_text).fetch
			if rs.nil?
			  insert.execute(news_text, href)
			end
		end
	end
end

