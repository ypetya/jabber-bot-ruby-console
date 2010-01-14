require 'net/http'
require 'uri'

def newl who, text

  if match_data = text.match(/^newl\s+(.*)/)

    if match_data2 = match_data[1].match(/(.{1,250})\s*:\s*(.*)/)
      title = match_data2[1]
      message = match_data2[2]
    else
      title = who.node
      message = match_data[1]
    end

    res = Net::HTTP.post_form(URI.parse('http://91.120.21.19/update'), {
      'magick'=> title, 
      'text'=> message, 
      'channel' => 8})
    @im.deliver who, 'ok'
  end
rescue Exception => e
  @im.deliver who,e.message
end

if defined? @@answer_bot
  @@answer_bot.add_filter :on_new_message, :newl
end
