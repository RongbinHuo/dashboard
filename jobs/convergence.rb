require 'pony'
require 'sanitize'
require 'mysql'

db_host  = "rongbin.cdpxz2jepyxw.us-east-1.rds.amazonaws.com"
db_user  = "root"
db_pass  = "12345678"
db_name = "twit"

# Populate the graph with some random points
points = []
(1..10).each do |i|
  points << { x: i, y: rand(5) }
end
last_x = points.last[:x]

SCHEDULER.every '2s' do
  conn = Mysql.new(db_host, db_user, db_pass, db_name)
  ts = (Time.now - (24*60*60)).strftime('%Y-%m-%d %H:%M:%S')
  rs = conn.query("SELECT COUNT(*) from gold_news where create_at > '#{ts}' ")
  tweets_count = rs.fetch_row[0].to_i

  points.shift
  last_x += 1
  points << { x: last_x, y: tweets_count }

  send_event('convergence', points: points)
end
