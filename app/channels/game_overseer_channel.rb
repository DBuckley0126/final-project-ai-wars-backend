class GameOverseerChannel < ApplicationCable::Channel
  def subscribed

    if !connection.user || !params["game_id"]
      reject
    end

    found_game = Game.find_by_id(params["game_id"])
    
    ready_game = found_game.add_user(connection.user)

    if ready_game
      stream_from "game_channel_##{ready_game.id}"
      stream_from "game_channel_##{ready_game.id}_for_user_##{connection.user.sub}"

      ActionCable.server.broadcast("game_channel_##{ready_game.id}_for_user_##{connection.user.sub}", 
        channel: "game_channel_##{ready_game.id}_for_user_##{connection.user.sub}", 
        type: "subscribed",
        action: "SUCCESSFULLY_SUBSCRIBED_TO_GAME",
        header: {},
        body: {game_id: ready_game.id}
      )

      serializerOptions = { 
        fields: { 
          game: [ 
            :capacity, 
            :uuid, 
            :host_user_ready, 
            :join_user_ready, 
            :game_initiated, 
            :host_user_colour, 
            :join_user_colour, 
            :join_user, 
            :host_user 
          ] 
        } 
      }

      ActionCable.server.broadcast("game_channel_##{ready_game.id}", 
        channel: "game_channel_##{ready_game.id}", 
        type: "update_game_lobby",
        action: "UPDATE_GAME_LOBBY",
        header: {},
        body: GameSerializer.new(ready_game, serializerOptions).serializable_hash
      )

    else
      reject
    end
  end

  def update_game_lobby

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
