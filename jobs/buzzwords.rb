require 'market_beat'

buzzwords = ['RT Pirce', 'Day Range', 'Change Percent', 'One day', '52 Week High', '200 Day Change', '50 Day Change', 'Year high change'] 
buzzword_counts = Hash.new({ value: 0 })

SCHEDULER.every '2s' do
  stock_price = MarketBeat.last_trade_real_time :DUST
  stock_day_range = MarketBeat.days_range_real_time :DUST
  stock_change_percent = MarketBeat.percent_change_real_time :DUST
  stock_one_day_change = MarketBeat.change_and_percent_change :DUST
  year_high = MarketBeat.high_52_week :DUST
  two_hundrad_days_change = MarketBeat.percent_change_from_200_day_moving_average :DUST
  fifty_days_change = MarketBeat.percent_change_from_50_day_moving_average :DUST
  percent_from_year_high = MarketBeat.percent_change_from_52_week_high :DUST
  buzzword_counts['Bid Pirce'] = { label: 'Bid Pirce', value: stock_price }
  # buzzword_counts['Day Range'] = { label: 'Day Range', value: stock_day_range }
  buzzword_counts['Change Percent'] = { label: 'Change Percent', value: stock_change_percent }
  buzzword_counts['One day'] = { label: 'One day', value: stock_one_day_change[1] }
  buzzword_counts['52 Week High'] = { label: '52 Week High', value: year_high }
  buzzword_counts['200 Day Change'] = { label: '200 Day Change', value: two_hundrad_days_change }
  buzzword_counts['50 Day Change'] = { label: '50 Day Change', value: fifty_days_change }
  buzzword_counts['Year high change'] = { label: 'Year high change', value: percent_from_year_high }
  
  send_event('buzzwords', { items: buzzword_counts.values })
end
