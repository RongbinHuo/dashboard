require 'market_beat'

buzzwords = ['RT Pirce', 'Day Range', 'Change Percent', 'One day', '52 Week High'] 
buzzword_counts = Hash.new({ value: 0 })

SCHEDULER.every '2s' do
  stock_price = MarketBeat.bid_real_time :AMZN
  stock_day_range = MarketBeat.days_range_real_time :AMZN
  stock_change_percent = MarketBeat.change_percent_real_time :AMZN
  stock_one_day_change = MarketBeat.change_and_percent_change :AMZN
  year_high = MarketBeat.high_52_week :AMZN
  buzzword_counts['Bid Pirce'] = { label: 'Bid Pirce', value: stock_price }
  buzzword_counts['Day Range'] = { label: 'Day Range', value: stock_day_range }
  buzzword_counts['Change Percent'] = { label: 'Change Percent', value: stock_change_percent }
  buzzword_counts['One day'] = { label: 'One day', value: stock_one_day_change[0] + "  " + stock_one_day_change[1] }
  buzzword_counts['52 Week High'] = { label: '52 Week High', value: year_high }

  send_event('buzzwords', { items: buzzword_counts.values })
end