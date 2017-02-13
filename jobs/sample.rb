require 'elasticsearch'
require 'market_beat'

client = Elasticsearch::Client.new log: false
last_value = 1
prediction_history = [0]
count = 0
SCHEDULER.every '600s' do
  count = count +1
  if count > 144
    count = 0
    prediction_history = [0]
  end

  predict_s = `python /home/ec2-user/twitt/predict_nn.py`
  predict = predict_s.to_f
  current_valuation = (predict*100).round(2)
  prediction_history.push(current_valuation)
  avg_price  = prediction_history.reduce(:+) / prediction_history.size.to_f

  send_event('valuation', { current: current_valuation, last: last_value })
  last_value = current_valuation
end

