require 'elasticsearch'



client = Elasticsearch::Client.new log: true
current_valuation = 0
current_karma = 0

SCHEDULER.every '2s' do
  tweets_count_result = client.search index: 'stocks', type: 'Amazon', body: { size: 0, aggs: { count_by_type: { terms: { field: '_type'}}}}
  tweets_count = tweets_count_result["aggregations"]["count_by_type"]["buckets"][0]["doc_count"]
  amazon_scoring_result = client.search index: 'stocks', type: 'Amazon', body: { size: 0, aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring = amazon_scoring_result["aggregations"]["avg_grade"]["value"]
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = tweets_count
  current_karma     = rand(200000)

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: (amazon_scoring*100).round(2) })
end

