require 'elasticsearch'


client = Elasticsearch::Client.new log: true
current_valuation = 0
current_karma = 0

SCHEDULER.every '2s' do
  date_now = Time.now.getutc.to_time.to_i
  date_passed_24_hours =  (Time.now.getutc - (24*60*60)).to_time.to_i
  date_three_hour = (Time.now.getutc - (3*60*60)).to_time.to_i

  # Count how many tweets have been ingested
  # tweets_count_result = client.search index: 'stocks', type: 'Amazon', body: { size: 0, aggs: { count_by_type: { terms: { field: '_type'}}}}
  # tweets_count = tweets_count_result["aggregations"]["count_by_type"]["buckets"][0]["doc_count"]

  # Scoring result for the past 24 hours
  amazon_scoring_result_24p = client.search index: 'stocks', type: 'Amazon', body: { size: 0, query: {
                                  range: {
                                    created_at: {
                                      gte: date_passed_24_hours,
                                      lte: date_now
                                    }
                                  }
                               },
                              aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring_24p = amazon_scoring_result_24p["aggregations"]["avg_grade"]["value"]

  #Scoring result for the past 3 hours

  amazon_scoring_result_3p = client.search index: 'stocks', type: 'Amazon', body: { size: 0, query: {
                                  range: {
                                    created_at: {
                                      gte: date_three_hour,
                                      lte: date_now
                                    }
                                  }
                               },
                              aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring_3p = amazon_scoring_result_3p["aggregations"]["avg_grade"]["value"]
  
  last_valuation = (amazon_scoring_24p*1000).round(2)
  last_karma     = amazon_scoring_24p
  current_valuation = (amazon_scoring_3p*1000).round(2)
  current_karma     = amazon_scoring_24p

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: (amazon_scoring_3p*1000).round(2) })
end

