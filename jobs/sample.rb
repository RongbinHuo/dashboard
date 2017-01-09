require 'elasticsearch'
require 'market_beat'

client = Elasticsearch::Client.new log: false
last_value = 0

SCHEDULER.every '2s' do
  # if !dust_scoring_3_to_2_p.nil? && !dust_scoring__all_avg.nil? && !dust_scoring_3_all_p.nil?
  #   scoring_increase_overall = (dust_scoring_3_to_2_p-dust_scoring__all_avg)/dust_scoring__all_avg
  #   scoring_increase_than_pre = (dust_scoring_3_to_2_p-dust_scoring_3_all_p)/dust_scoring_3_all_p
  
  #   # predict_s = %x(python /home/ec2-user/twitt/predict.py -0.66410813 -0.66404772 /home/ec2-user/twitt/model/model.pkl)
  #   predict_s = `python /home/ec2-user/twitt/predict_decision_tree.py #{scoring_increase_overall} #{scoring_increase_than_pre} #{quote_data_year_percent} #{quote_data_day_percent} /home/ec2-user/twitt/model/decision_tree.pkl`
  #   score_percent = predict_s.to_f
  #   predict = predict_s.to_f
  #   # if score_percent > 0.3
  #   #   predict = score_percent/0.5
  #   # elsif score_percent < 0.2
  #   #   predict = -(0.2-score_percent)/0.3
  #   # else
  #   #   predict = (score_percent-0.25)/0.1
  #   # end
  # else
  #   predict_s = `python /home/ec2-user/twitt/predict_decision_tree.py 0 0 0 0 /home/ec2-user/twitt/model/decision_tree.pkl`
  #   predict = predict_s.to_f
  # end

  predict_s = `python /home/ec2-user/twitt/predict_nn.py`
  predict = predict_s.to_f

  last_valuation = (dust_scoring__all_avg*1000).round(2)
  last_karma     = dust_scoring__all_avg
  current_valuation = predict * 100
  # current_karma     = dust_scoring__all_avg

  send_event('valuation', { current: current_valuation, last: last_value })
  # send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: (predict*100).round(2) })
  last_value = current_valuation
end

