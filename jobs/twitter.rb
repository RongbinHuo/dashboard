require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'i6a3NjwywEkGFAfSYLgv939D0'
  config.consumer_secret = 'kDQxTLEnF6W6D26sQKV5BWP9Iu0f94nRlqKFVcmeGLrtOS7egS'
  config.access_token = '779040390263480320-tX16RcbylE0Gkimy5Cun5yOnABOClrB'
  config.access_token_secret = 'EkwfeQHGS2EJiZIOzRQ1ZDhUNqe0hD6kNRPMzvr7NlLBd'
end

search_term = URI::encode('$DUST')

SCHEDULER.every '5m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")
    content_ary = []
    if tweets
      tweets_ary = twitter.search("#{search_term}").first(3)
      tweets_ary.each do |t|
        content = ''
        if t
          content_test = t.text.dup 
          content << content_test.strip+' --- '+t.created_at.to_s
          content_ary.push(content)
        end
      end
      # tweets = tweets.map do |tweet|
      #   { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https,  }
      # end
      send_event('twitter_mentions', items: content_ary)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end
