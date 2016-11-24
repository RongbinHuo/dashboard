require 'twitter'
require 'time'
require 'active_support/time'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'i6a3NjwywEkGFAfSYLgv939D0'
  config.consumer_secret = 'kDQxTLEnF6W6D26sQKV5BWP9Iu0f94nRlqKFVcmeGLrtOS7egS'
  config.access_token = '779040390263480320-tX16RcbylE0Gkimy5Cun5yOnABOClrB'
  config.access_token_secret = 'EkwfeQHGS2EJiZIOzRQ1ZDhUNqe0hD6kNRPMzvr7NlLBd'
end

search_term = URI::encode('$DUST')
important_words = ['gold','dollar','fed','rate','debt','bond','economy','equity','interest','data','inflation','risk']
SCHEDULER.every '1m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")
    content_ary = []
    count_tweets = 0
    if tweets
      tweets_ary = twitter.search("#{search_term}").first(100)
      tweets_ary.each do |t|
        content = ''
        if t
          content_test = t.text.dup
          if important_words.any?{|w| content_test.include?(w)}
            time_utc =  Time.parse(t.created_at.to_s)
            time_ect = time_utc.in_time_zone("Eastern Time (US & Canada)")
            content << content_test.gsub!(/(?:f|ht)tps?:\/[^\s]+/, '').strip+' --- '+time_ect.to_s
            content_ary.push(content)
            count_tweets = count_tweets + 1
          end
        end
        if count_tweets > 3
          break
        end
      end
      send_event('twitter_mentions', items: content_ary)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end
