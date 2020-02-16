module GameInstancesOverseerActions

  def self.update_game_instances
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

    ActionCable.server.broadcast("game_instances_overseer_channel", 
      channel: "game_instances_overseer_channel", 
      type: "update_game_instances",
      action: "UPDATE_GAME_INSTANCES",
      header: {},
      body: GameSerializer.new(Game.uninitialized_games, serializerOptions).serializable_hash
    )
  end

  def self.update_game_lobby(lobby)
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

    if lobby.uuid
      ActionCable.server.broadcast("game_channel_##{lobby.uuid}", 
        channel: "game_channel_##{lobby.uuid}", 
        type: "update_game_lobby",
        action: "UPDATE_GAME_LOBBY",
        header: {},
        body: GameSerializer.new(lobby, serializerOptions).serializable_hash
      )
    end

  end

end