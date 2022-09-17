class PostsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "PostsChannel"
  end

  def receive(data)
  end

  def unsubscribed
    stop_all_streams
  end
end
