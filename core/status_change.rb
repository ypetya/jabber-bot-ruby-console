
# This handler will handle all of our new updates

def on_status_change
  @filters[:on_status_change] || []
end

def presence_updates
  presence_updates! do |*params|
    on_status_change.each do |filter|
      with_exceptions do
        run_filter filter,*params
      end
    end
  end
end

def presence_updates!
  @im.presence_updates.each do |x|
    puts " * #{x[0]} is #{x[1]} : #{x[2]} "
    yield *x
  end
end

@@answer_bot.add_filter :on_tick, :presence_updates
