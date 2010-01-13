#!/usr/bin/env ruby

# gem install sishen-rtranslate --source http://gems.github.com --no-ri --no-rdoc
# >= 1.2
require 'rtranslate'

if defined? @@answer_bot

  @@answer_bot.filters[:on_new_message] << lambda do |who,what|

    # translate -> translate en this text

    if m = what.match(/^translate\s+(\w+)\s+(.*)/)
      @@answer_bot.im.deliver(who,Translate.t(m[2],'',m[1]))

    # detect -> language detection

    elsif m = what.match(/^detect\s+(.*)/)
      @@answer_bot.im.deliver(who,Translate.d(m[1]))
    end
  end
end
