require 'open-uri'
require 'nokogiri'

url = 'https://www.bulliondesk.com/gold-news/'

# news = Hash.new({ value: 0 })
news = []
SCHEDULER.every '20s' do
  html = open(url)
  doc = Nokogiri::HTML(html)
  doc.css('artical')

  latest_news_content = doc.css('section#news-top h2').text.strip()
  latest_new_timestamp = doc.css('section#news-top div.meta').text.strip()
  latest_news_url = doc.css('section#news-top a')[0]['href'].strip()

  basic_news1_content = doc.css('section#news-feature article h4')[0].text.strip()
  basic_news1_timestamp = doc.css('section#news-feature article div.meta')[0].text.strip()
  basic_news1_url = doc.css('section#news-feature article h4 a')[0]['href'].strip()

  basic_news2_content = doc.css('section#news-feature').css("article")[1].css("h4").text.strip()
  basic_news2_timestamp = doc.css('section#news-feature').css("article")[1].css("div.meta").text.strip()
  basic_news2_url = doc.css('section#news-feature article h4 a')[1]['href'].strip()
  
  # news['latest'] = { content: latest_news_content, time: latest_new_timestamp, url:  latest_news_url}
  # news['basic1'] = { content: basic_news1_content, time: basic_news1_timestamp, url:  basic_news1_url}
  # news['basic2'] = { content: basic_news2_content, time: basic_news2_timestamp, url:  basic_news2_url}
  news.push(latest_news_content)
  news.push(basic_news1_content)
  news.push(basic_news2_content)

  send_event('gold_news', items: news)
end
