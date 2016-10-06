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
insert_with_datetime = conn.prepare('INSERT INTO gold_news (text, link, news_date) VALUES(?, ?, ?)')

url_usagold = 'http://www.usagold.com/dailyquotes.html'

url_kitco = 'http://www.kitco.com/market/marketnews.html'

SCHEDULER.every '600s' do
	html_usagold = open(url_usagold)
	doc_usagold = Nokogiri::HTML(html_usagold)

	news_time_source_usagold = doc_usagold.css('span.txtarial11 table tr td[valign="TOP"]')

	news_time_source_usagold.each do |n|
		if n["align"].nil?
		    news_text = n.text.strip()
			href = n.css('font a')[0]['href'].strip()
			rs = check_query.execute(news_text).fetch
			if rs.nil?
			    insert.execute(news_text, href)
			end
		end
	end

	html_kitco = open(url_kitco)
	doc_kitco = Nokogiri::HTML(html_kitco)
	news_time_source_kitco = doc_kitco.css('div .gold')
	news_time_source_kitco.each do |n|
	    news_text = n.css('.article-title').text.strip()
	    news_time = n.css('.post-date').text.strip()
	    news_href = 'http://www.kitco.com'+n.css('a')[0]['href'].strip()
	    rs = check_query.execute(news_text).fetch
	    if rs.nil?
	    	insert_with_datetime.execute(news_text, news_href, news_time)
	    end
	end
end

