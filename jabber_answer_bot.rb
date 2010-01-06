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

require 'json'
require 'xmpp4r-simple'

class AnswerBot
 
  attr_accessor :im

  def initialize user, pwd
    @im = Jabber::Simple.new(user,pwd)
    @im.accept_subscriptions = true unless @im.accept_subscriptions?
    trap "SIGINT", method(:stop!)
    reset_filters!
  end

  def reset_filters!
    @filters = {
          :on_status_change => [],
          :on_new_buddy => [ :default_new_buddy ],
          :on_new_message => [ :eval_command ]
        }
  end

  def add_filter key, the_proc
    unless @filters[key]
      false
    else
      @filters[key] << the_proc
      true
    end
  end

  def stop!(*args)
    debug "AnswerBot: Received SIGINT, exiting."
    @break = true
  end
  
  def run
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
    case @@master
    when String
      @im.deliver @@master, msg
    when Array
      @@master.each{|m| @im.deliver m,msg }
    else
      puts " DEBUG : #{msg} "
    end
  end

  def presence_updates!
    @im.presence_updates.each do |x|
      puts " * #{x[0]} is #{x[1]} : #{x[2]} "
      yield *x
    end
  end

  def accept_buddies!
    @im.new_subscriptions.each do |subscription|
      subscription.each do |elem|
        if elem.is_a? Jabber::Roster::Helper::RosterItem
          puts "Subscribed: #{ elem.jid.to_s }!"
          yield( elem.jid )
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
    yield
  rescue Exception => e
    debug <<-EOT 
  #{e.message}
  #{e.backtrace.join("\n")}
EOT
  end

  def run_filter filter,*params
    case filter
    when Symbol
      send(filter,*params)
    when Proc
      filter.call(*params)
    end
  end

  def default_new_buddy new_buddy
    @im.deliver new_buddy.to_s,"Hi #{new_buddy.node}!"
  end

  def main_loop
    presence_updates! do |*params|
      @filters[:on_status_change].each do |filter|
        with_exceptions do
          run_filter filter,*params
        end
      end
    end

    accept_buddies! do |new_buddy|
      @filters[:on_new_buddy].each do |filter|
        with_exceptions do
          run_filter filter,new_buddy
        end
      end
    end

    parse_messages! do |*params|
      @filters[:on_new_message].each do |filter|
        with_exceptions do
          run_filter( filter,*params )
        end
      end
    end
  end
end

@@b = AnswerBot.new(*@@settings[:jabberbot])
@@b.run

