require 'mysql'
require 'open-uri'
require 'nokogiri'
require 'mechanize'

db_host  = "rongbin.cdpxz2jepyxw.us-east-1.rds.amazonaws.com"
db_user  = "root"
db_pass  = "12345678"
db_name = "twit"


url_usagold = 'http://www.usagold.com/dailyquotes.html'

url_kitco = 'http://www.kitco.com/market/marketnews.html'

url_investing = 'https://www.investing.com/commodities/gold-news'

url_bullionvault = 'https://www.bullionvault.com/gold-news'

url_silverdoctors = 'http://www.silverdoctors.com/gold/gold-news/'

url_cnbc = 'http://www.cnbc.com/gold/'

url_economictimes = 'http://economictimes.indiatimes.com/topic/Gold'

SCHEDULER.every '300s' do

	conn = Mysql.new(db_host, db_user, db_pass, db_name)
	check_query = conn.prepare('SELECT * from gold_news where link = (?)')
	insert = conn.prepare('INSERT INTO gold_news (text, link) VALUES(?, ?)')
	insert_with_datetime = conn.prepare('INSERT INTO gold_news (text, link, news_date) VALUES(?, ?, ?)')

	begin
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
	rescue; end

	begin
		agent = Mechanize.new
		page = agent.get url_kitco
		# html_kitco = open(url_kitco)
		doc_kitco = Nokogiri::HTML(page.content)
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
	rescue; end

	begin
		html_investing = open(url_investing)
		doc_investing = Nokogiri::HTML(html_investing)
		news_time_source_investing = doc_investing.css('div .mediumTitle1 .articleItem')
		news_time_source_investing.each do |n|
			news_entry = n.css('div')[0].css('a')
			news_text = news_entry.text.strip()
			raw_href = news_entry[0]['href'].strip()
			news_href = raw_href
			if raw_href.start_with?('/')
				news_href = 'https://www.investing.com'+raw_href
			end
			rs = check_query.execute(news_href).fetch
			if rs.nil?
		    	insert.execute(news_text, news_href)
		    end
		end
	rescue; end

	begin
		html_bullionvault = open(url_bullionvault)
		doc_bullionvault = Nokogiri::HTML(html_bullionvault)
		news_bullionvault = doc_bullionvault.css('.view-content table tbody tr')
		news_bullionvault.each do |n|
			news_text = n.css('td a').text.strip
			raw_href = n.css('td a')[0]['href'].strip()
			news_href = raw_href
			if raw_href.start_with?('/')
				news_href = 'https://www.bullionvault.com'+raw_href
			end
			rs = check_query.execute(news_href).fetch
			if rs.nil?
		    	insert.execute(news_text, news_href)
		    end
		end
	rescue; end

	begin
		html_silverdoctors = open(url_silverdoctors)
		doc_silverdoctors = Nokogiri::HTML(html_silverdoctors)
		news_silverdoctors = doc_silverdoctors.css('div#archive-content-column div.index-article')
		news_silverdoctors.each do |n|
			news_text = n.css('.page-title a').text.strip
			raw_href = n.css('.page-title a')[0]['href'].strip()
			news_href = raw_href
			if raw_href.start_with?('/')
				news_href = 'http://www.silverdoctors.com/gold/gold-news'+raw_href
			end
			rs = check_query.execute(news_href).fetch
			if rs.nil?
		    	insert.execute(news_text, news_href)
		    end
		end
	rescue; end

	begin
		html_cnbc = open(url_cnbc)
		doc_cnbc = Nokogiri::HTML(html_cnbc)
		news_cnbc = doc_cnbc.css('div.stories-lineup li')
		news_cnbc.each do |n|
			news_text = n.css('.headline').text.strip
			raw_href = n.css('.headline a')[0]['href'].strip()
			news_href = raw_href
			if raw_href.start_with?('/')
				news_href = 'http://www.cnbc.com'+raw_href
			end
			rs = check_query.execute(news_href).fetch
			if rs.nil?
		    	insert.execute(news_text, news_href)
		    end
		end
	rescue; end

	begin
		html_economictimes = open(url_economictimes)
		doc_economictimes = Nokogiri::HTML(html_economictimes)
		news_economictimes = doc_economictimes.css('li#all div')
		news_economictimes.each do |n|
			news_text = n.css('a h3').text.strip
			raw_href = n.css('a')[0]['href'].strip()
			news_href = raw_href
			if raw_href.start_with?('/')
				news_href = 'http://economictimes.indiatimes.com'+raw_href
			end
			rs = check_query.execute(news_href).fetch
			if rs.nil?
		    	insert.execute(news_text, news_href)
		    end
		end
	rescue; end

	conn.close
end





