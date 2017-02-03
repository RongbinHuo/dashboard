require 'mysql'
require 'open-uri'
require 'nokogiri'

db_host  = "rongbin.cdpxz2jepyxw.us-east-1.rds.amazonaws.com"
db_user  = "root"
db_pass  = "12345678"
db_name = "twit"


url_usagold = 'http://www.usagold.com/dailyquotes.html'

url_kitco = 'http://www.kitco.com/market/marketnews.html'

url_sharps = 'http://info.sharpspixley.com/news/gold-news/'

url_investing = 'https://www.investing.com/commodities/gold-news'


SCHEDULER.every '300s' do

	conn = Mysql.new(db_host, db_user, db_pass, db_name)
	check_query = conn.prepare('SELECT * from gold_news where link = (?)')
	insert = conn.prepare('INSERT INTO gold_news (text, link) VALUES(?, ?)')
	insert_with_datetime = conn.prepare('INSERT INTO gold_news (text, link, news_date) VALUES(?, ?, ?)')

	html_usagold = open(url_usagold)
	doc_usagold = Nokogiri::HTML(html_usagold)
	news_time_source_usagold = doc_usagold.css('span.txtarial11 table tr td[valign="TOP"]')
	news_time_source_usagold.each do |n|
		if n["align"].nil?
		    news_text = n.text.strip()
			href = n.css('font a')[0]['href'].strip()
			rs = check_query.execute(href).fetch
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
	    news_time_str = n.css('.post-date').text.strip()
	    news_time = Time.parse(news_time_str)
	    raw_href = n.css('a')[0]['href'].strip()
	    news_href = raw_href
	    if raw_href.start_with?('/')
	    	news_href = 'http://www.kitco.com'+raw_href
	    end
	    rs = check_query.execute(news_href).fetch
	    if rs.nil?
	    	insert_with_datetime.execute(news_text, news_href, news_time)
	    end
	end

	html_sharps = open(url_sharps)
	doc_sharps = Nokogiri::HTML(html_sharps)
	news_time_source_shaprs = doc_sharps.css('div.newsTable li')
	news_time_source_shaprs.each do |n|
		news_text = n.text.strip()
		news_time = Time.parse(n.css('.Date').text.strip())
		news_href =  n.css('a')[0]['href'].strip()
		rs = check_query.execute(news_href).fetch
		if rs.nil?
			insert_with_datetime.execute(news_text, news_href, news_time)
		end
	end

	html_investing = open(url_investing)
	doc_investing = Nokogiri::HTML(html_investing)
	news_time_source_investing = doc_investing.css('div .mediumTitle1 .articleItem')
	news_time_source_investing.each do |n|
		news_entry = n.css('div')[0].css('a')
		news_text = news_entry.text.strip()
		raw_href = news_entry[0]['href'].strip()
		news_href = raw_href
		if raw_href.start_with?('/')
			news_href = 'https://www.investing.com/commodities/gold-news'+raw_href
		end
		rs = check_query.execute(news_href).fetch
		if rs.nil?
	    	insert.execute(news_text, news_href)
	    end
	end

	conn.close
end





