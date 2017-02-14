SCHEDULER.every '10800s' do
  ingest_script = `python /home/ec2-user/twitt/ingest_to_details.py`
end
