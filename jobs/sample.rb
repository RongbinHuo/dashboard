require 'elasticsearch'
require 'market_beat'

client = Elasticsearch::Client.new log: false
current_valuation = 0
current_karma = 0

SCHEDULER.every '2s' do
  date_now = Time.now.getutc.to_time.to_i
  date_three_hour = (Time.now.getutc - (3*60*60)).to_time.to_i

  time_range_start = (Time.now.getutc - (3*60*60)).to_time.to_i
  time_range_end = (Time.now.getutc - (2*60*60)).to_time.to_i

  # Count how many tweets have been ingested
  # tweets_count_result = client.search index: 'stocks', type: 'Amazon', body: { size: 0, aggs: { count_by_type: { terms: { field: '_type'}}}}
  # tweets_count = tweets_count_result["aggregations"]["count_by_type"]["buckets"][0]["doc_count"]

  # Scoring result for the past
  amazon_scoring_result_all_avg = client.search index: 'stocks', type: 'Amazon', body: { size: 0,
                              aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring__all_avg = amazon_scoring_result_all_avg["aggregations"]["avg_grade"]["value"]

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

  amazon_scoring_result_3_to_2_p = client.search index: 'stocks', type: 'Amazon', body: { size: 0, query: {
                                  range: {
                                    created_at: {
                                      gte: time_range_start,
                                      lte: time_range_end
                                    }
                                  }
                               },
                              aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring_3_to_2_p = amazon_scoring_result_3p["aggregations"]["avg_grade"]["value"]

  amazon_scoring_result_3_all_p = client.search index: 'stocks', type: 'Amazon', body: { size: 0, query: {
                                  range: {
                                    created_at: {
                                      lte: time_range_start
                                    }
                                  }
                               },
                              aggs: { avg_grade: { avg: { field: 'scoring'}}}}
  amazon_scoring_3_all_p = amazon_scoring_result_3_all_p["aggregations"]["avg_grade"]["value"]
  if !scoring_increase_overall.nil? && !amazon_scoring__all_avg.nil? && !amazon_scoring_3_all_p.nil?
    scoring_increase_overall = (amazon_scoring_3_to_2_p-amazon_scoring__all_avg)/amazon_scoring__all_avg
    scoring_increase_than_pre = (amazon_scoring_3_to_2_p-amazon_scoring_3_all_p)/amazon_scoring_3_all_p
  
    predict_s = %x(python /home/ec2-user/twitt/predict.py -0.66410813 -0.66404772 /home/ec2-user/twitt/model/model.pkl)
    predict = predict_s.to_f
  else
    predict = 0

  last_valuation = (amazon_scoring__all_avg*1000).round(2)
  last_karma     = amazon_scoring__all_avg
  current_valuation = (amazon_scoring_3p*1000).round(2)
  current_karma     = amazon_scoring__all_avg

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: (predict*10).round(2) })
end

