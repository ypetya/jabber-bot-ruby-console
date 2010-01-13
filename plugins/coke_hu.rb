#!/usr/bin/env ruby

require 'rubygems'

require 'nokogiri'
require 'mechanize'

@@agent, @@agent.user_agent_alias, @@agent.redirect_ok = WWW::Mechanize.new, 'Linux Mozilla', true

def post_code_to_coke_hu who,msg
  if match_data = msg.match(/^kupak\s+(.*)/)
    codes = match_data[1].split(",").split(" ").split(";")

    o = @@agent.get 'http://coke.hu'

    if not o.forms.empty? and o.forms.first.name == 'loginbox'
      l = o.forms.first
      l.username,l.password = *@@settings[:coke_hu]
      o = l.submit
    end

    codes.each do |code|
      @@agent.post('https://secure.coke.hu','action' => 'registerwincode', 'stayloggedin' => 'true', 'wincode' => code)
      puts "posted code: #{code}"
    end

    @im.deliver who, "Codes sended: #{codes.join(",")}"
  end
end

if defined? @@answer_bot
  @@answer_bot.add_filter :on_new_message, :post_code_to_coke_hu
end

