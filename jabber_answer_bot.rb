#!/usr/bin/env ruby

# == help
# okay. 
# it was started to a very-very simple answer to answer chatbot
# but. there is a filter - plugin system implemented, inside that bot.
# @@masters can evaulate ruby code inside. its like script injection, but more. 
# every master gots the exceptions and the backtraces.
# if you are a @@master you can invite others to master. or even more.
# evaulated code is always passed back in JSON format.
# do something! develop in the chat window! solve problems!
# like make a repository! for your new plugins! remote!

load '/etc/my_ruby_scripts/settings.rb'

@@master = ['ypetya@gmail.com']

DIR = ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH']

require 'rubygems'
require 'json'
require 'xmpp4r-simple'

class AnswerBot
 
  attr_accessor :im,:filters

  def initialize user, pwd
    @im = Jabber::Simple.new(user,pwd)
    @im.accept_subscriptions = true unless @im.accept_subscriptions?
    trap "SIGINT", method(:stop!)
    reset_filters!
  end

  def reset_filters!
    @filters = {
#          :on_status_change => [],
#          :on_new_buddy => [],
          :on_new_message => [ :eval_command ],
          :on_tick => [:parse_messages]
        }
  end

  def add_filter key, the_proc
    @filters[key] ||= []
    unless @filters[key]
      @filters[key] << the_proc
    end
  end

  def remove_filter key, the_proc_key
    @filters[key] ||=[]
    @filters[key].delete the_proc
  end

  def stop!(*args)
    debug "AnswerBot: Received SIGINT, exiting."
    @break = true
    exit(0)
  end
  
  def run
    sleep 1
    debug 'AnswerBot: Started!'
    @break = false

    while not @break do
      if @im.connected?
        main_loop
      else
        @im.reconnect
      end

      sleep 5
    end

    @im.disconnect
  end

  protected

  def debug msg
    @@master.each{|m| @im.deliver m,msg }
  end

  def parse_messages
    parse_messages! do |*params|
      @filters[:on_new_message].each do |filter|
        with_exceptions do
          run_filter( filter,*params )
        end
      end
    end
  end

  def parse_messages!
    @im.received_messages.select{|m| m.type == :chat}.each do |message|
      puts "Received: #{message.body[0..25]}"
      yield(message.from,message.body)
    end
  end

  # this is the main why. thatswhy we've written this code.
  def eval_command who,what
    if [@@master].flatten.include?("#{who.node}@#{who.domain}")
      res = eval(what)
      @im.deliver( who, res.is_a?(String) ? res : res.to_json)
    end
  end

  def with_exceptions
    Thread.new do
      begin
        yield
      rescue Exception => e
        debug <<-EOT 
        #{e.message}
        #{e.backtrace.join("\n")}
        EOT
      end
    end
  end

  def run_filter filter,*params
    case filter
    when Symbol
      send(filter,*params)
    when Proc
      filter.call(*params)
    end
  end

  # okay, so there are some functions to call 
  # other event handlers too :)
  def main_loop
    @filters[:on_tick].each do |filter|
      with_exceptions do
        run_filter filter
      end
    end
  end
end

@@answer_bot = AnswerBot.new(*@@settings[:jabberbot])
@@answer_bot.run

