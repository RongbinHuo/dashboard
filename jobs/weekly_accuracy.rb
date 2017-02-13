last_acuracy = 1
acuracy_history = [0]
count = 0
SCHEDULER.every '3600s' do
  count = count +1
  if count > 144
    count = 0
    acuracy_history = [0]
  end

  acuracy_s = `python /home/ec2-user/twitt/weekly_acuracy.py`
  acuracy = acuracy_s.to_f
  current_acuracy = (acuracy*100).round(2)
  acuracy_history.push(current_acuracy)

  send_event('weekly_acuracy', { current: current_acuracy, last: last_acuracy })
  last_acuracy= current_acuracy
end

