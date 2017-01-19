SCHEDULER.every '600s' do

  predict_s = `python /home/ec2-user/twitt/predict_yesterday.py`
  predict = predict_s.to_f

  # last_valuation = (dust_scoring__all_avg*1000).round(2)
  # last_karma     = dust_scoring__all_avg
  yesterday_valuation = (predict*100).round(2)
  send_event('synergy',   { value: yesterday_valuation })
end

