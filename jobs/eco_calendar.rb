require 'open-uri'
require 'nokogiri'

url = 'https://www.dailyfx.com/calendar'
dow = Time.now.wday
cal_class = '#daily-cal'+dow.to_s
# news = Hash.new({ value: 0 })
news = []
SCHEDULER.every '20s' do
  html = open(url)
  doc = Nokogiri::HTML(html)
  all_events = doc.css("#{cal_class} tbody tr")
  all_events.each_with_index do |e,i|
    if e["data-importance"] == 'high'
      date_time = e.css('td')[1].children.text
      topic_raw = a["data-search"]
      topic = topic_raw.slice(0,1).capitalize + topic_raw.slice(1..-1)
      news.push(date_time + "  :  " + topic)
    end
  end

  send_event('calendar', items: news)
end
