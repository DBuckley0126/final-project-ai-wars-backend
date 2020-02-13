class GameInstancesOverseerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_instances_overseer_channel"
    AppChannel.broadcast_to("game_instances_overseer_channel", 
      channel: "game_instances_overseer_channel", 
      type: "subscribed",
      action: "SUCCESSFULLY_SUBSCRIBED",
      header: {},
      body: {}
    )
  end

  def game_instances(data)

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
