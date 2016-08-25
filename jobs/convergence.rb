require 'elasticsearch'
# Populate the graph with some random points

client = Elasticsearch::Client.new log: true
points = []
(1..10).each do |i|
  points << { x: i, y: rand(50) }
end
last_x = points.last[:x]

SCHEDULER.every '2s' do
  tweets_count_result = client.search index: 'stocks', type: 'Amazon', body: { size: 0, aggs: { count_by_type: { terms: { field: '_type'}}}}
  tweets_count = tweets_count_result["aggregations"]["count_by_type"]["buckets"][0]["doc_count"]
  # points.shift
  # last_x += 1
  # points << { x: last_x, y: rand(50) }

  send_event('convergence', points: tweets_count)
end