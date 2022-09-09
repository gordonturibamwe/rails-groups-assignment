class GroupsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "GroupsChannel"
  end

  def receive(data)
  end

  def unsubscribed
    stop_all_streams
  end
end
