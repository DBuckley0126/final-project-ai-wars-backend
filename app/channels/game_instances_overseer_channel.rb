class GameInstancesOverseerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_instances_overseer_channel"
    stream_from "game_instances_overseer_channel_##{connection.user.sub}"

    Game.create(user_1: User.first)

    ActionCable.server.broadcast("game_instances_overseer_channel_##{connection.user.sub}", 
      channel: "game_instances_overseer_channel_##{connection.user.sub}", 
      type: "subscribed",
      action: "SUCCESSFULLY_SUBSCRIBED",
      header: {},
      body: {}
    )


    ActionCable.server.broadcast("game_instances_overseer_channel_##{connection.user.sub}", 
      channel: "game_instances_overseer_channel_##{connection.user.sub}", 
      type: "subscribed",
      action: "UPDATE_GAME_INSTANCES",
      header: {},
      body: GameSerializer.new(Game.uninitialized_games).serializable_hash
    )
  end

  def game_instances(data)

  end

  def join_game(data)
    ActionCable.server.broadcast("game_instances_overseer_channel", 
      channel: "game_instances_overseer_channel", 
      type: "subscribed",
      action: "SUCCESSFULLY_SUBSCRIBED",
      header: {},
      body: {}
    )
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
