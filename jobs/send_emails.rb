require 'pony'
require_relative '../config/conf'
require 'sanitize'
require 'mysql'

db_host  = "rongbin.cdpxz2jepyxw.us-east-1.rds.amazonaws.com"
db_user  = "root"
db_pass  = "12345678"
db_name = "twit"

def self.send_email(subject, message)
    Pony.mail({
	  :to => Conf.app[:mail_to],
	  :via => :smtp,
	  :via_options => {
	    :address              => 'smtp.gmail.com',
	    :port                 => '587',
	    :enable_starttls_auto => true,
	    :user_name            => Conf.app[:user_name],
	    :password             => Conf.app[:password],
	    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
	  },
	  :subject => subject,
	  :html_body => message, 
	  :body => html_to_plain_text(message)
	})
end

def html_to_plain_text s
    s = s.gsub(/<(br|p|div|\/li)[^>]*>\n?/,"\n")
         .gsub(/<li[^>]*>/,"\t* ")
         .gsub(/<a[^>]*href=["']?([^>]*)["'][^>]*>(.*)<\/a>?/,'\2[\1]')
    Sanitize.fragment(s)
end

def build_message row
	message = "<p><a href='#{row[1]}' style='font-size: 20px; text-decoration: none'> #{row[0]} </a></p>"
end

SCHEDULER.cron '0 12 * * *' do
	conn = Mysql.new(db_host, db_user, db_pass, db_name)
	ts = (Time.now - (12*60*60)).strftime('%Y-%m-%d %H:%M:%S')
	rs = conn.query("SELECT text, link, news_date from gold_news where create_at > #{ts}")
	message = '<h2>Todays Gold News</h2>'
	subject = 'Todays Gold News'
	rs.each do |row|
		message << build_message(row)
	end
	send_email(subject, message)
end
