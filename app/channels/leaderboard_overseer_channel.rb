class GameOverseerChannel < ApplicationCable::Channel
  def subscribed
    stream_for "leaderboard_channel"
    AppChannel.broadcast_to("app_channel", )
  end

  def app_data(data)
    
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
