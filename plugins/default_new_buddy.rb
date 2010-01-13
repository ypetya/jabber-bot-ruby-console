#!/usr/bin/env ruby

require 'core/status_change'

# it will greet all new buddies, with Hi!

def default_new_buddy new_buddy
  @im.deliver new_buddy.to_s,"Hi #{new_buddy.node}!"
end

if defined?( @@answer_bot )
  @@answer_bot.add_filter :on_new_buddy,:default_new_buddy
end
