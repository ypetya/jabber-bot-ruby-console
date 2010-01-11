
def on_new_buddy
  @filters[:on_new_buddy] || []
end

def accept_buddies 
  accept_buddies! do |new_buddy|
    on_new_buddy.each do |filter|
      with_exceptions do
        run_filter filter,new_buddy
      end
    end
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

@@answer_bot.add_filter :on_tick, :accept_buddies
