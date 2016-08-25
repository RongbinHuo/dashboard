require 'market_beat'

buzzwords = ['Bid Pirce', 'Day Range', 'Change Percent', 'After hour change'] 
buzzword_counts = Hash.new({ value: 0 })

SCHEDULER.every '2s' do
  stock_price = MarketBeat.bid_real_time :AMZN
  stock_day_range = MarketBeat.days_range_real_time :AMZN
  stock_change_percent = MarketBeat.change_percent_real_time :AMZN
  stock_after_hours_change = MarketBeat.after_hours_change_real_time :AMZN
  # random_buzzword = buzzwords.sample
  # buzzword_counts[random_buzzword] = { label: random_buzzword, value: (buzzword_counts[random_buzzword][:value] + 1) % 30 }
  buzzword_counts[random_buzzword] = { label: 'Bid Pirce', value: stock_price }
  buzzword_counts[random_buzzword] = { label: 'Day Range', value: stock_day_range }
  buzzword_counts[random_buzzword] = { label: 'Change Percent', value: stock_change_percent }
  buzzword_counts[random_buzzword] = { label: 'After hour change', value: stock_after_hours_change }
  send_event('buzzwords', { items: buzzword_counts.values })
end