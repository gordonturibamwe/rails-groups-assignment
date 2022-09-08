class UsersGroupChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "UsersGroupChannel"
  end

  def receive(data)
    puts "-----+++++ #{data.inspect}"
    # ActionCable.server.broadcast "GroupsChannel", data
  end

  def unsubscribed
    stop_all_streams
  end
end
