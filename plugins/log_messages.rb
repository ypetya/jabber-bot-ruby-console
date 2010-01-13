#!/usr/bin/env ruby

# it will log out every message 

def log_message who,what
  File.open('jabber_bot.log','w') do |f|
    f.puts "#{Time.now.strftime( '%Y.%m.%d. %H:%M:%S')} #{who}: #{what}"
  end
end

if defined?( @@answer_bot ) and not @@answer_bot.filters[:on_new_message].include?( :log_message )
  @@answer_bot.filters[:on_new_message].unshift :log_message
end
