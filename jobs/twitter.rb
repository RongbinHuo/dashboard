require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = 'UC9BS80NQnafk5o2uU5xie0DS'
  config.consumer_secret = 'OS8CrYpVTZcOXxnKDAARySBKGNCsXtE1k5YTmWfJGcvyWHJ8S6'
  config.access_token = '861777992-0jnfEW317U6UPG2zj74dY3baslvh2Bd5mBOHxvMr'
  config.access_token_secret = 'ueIysJeHEBQuvHVtZnsYu2WEv9mCDznpSbkPgyUxEsuNm'
end

search_term = URI::encode('$DUST')

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")

    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', text: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end
