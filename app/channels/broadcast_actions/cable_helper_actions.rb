module CableHelperActions

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

  def self.update_game_of_turn(turn)
    game_serializer_options = { 
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
          :host_user,
          :turn_count
        ]
      } 
    }

    spawners_serializer_options = { 
      fields: { 
        spawner: [
          :active,
          :colour, 
          :skill_points, 
          :passed_initial_test, 
          :error, 
          :cancelled, 
          :error_history_array, 
          :spawner_name
        ]
      } 
    }

    unit_serializer_options = { 
      fields: { 
        unit: [
          :uuid, 
          :attribute_health, 
          :coordinate_Y, 
          :coordinate_X, 
          :base_health, 
          :base_movement, 
          :base_range, 
          :base_melee, 
          :base_vision,
          :base_spawn_position,
          :data_set, 
          :error_history_array, 
          :movement_history, 
          :colour, 
          :unit_output_history_array, 
          :active, 
          :new,
          :error, 
          :cancelled,
          :current_path,
          :target_coordinate_string,
          :path_step_count,
          :obstacle
        ]
      } 
    }

    turn_serializer_options = { 
      fields: { 
        turn: [
          :uuid, 
          :turn_count,
          :map_states_for_turn, 
          :game, 
          :user
        ]
      } 
    }

    ActionCable.server.broadcast("game_channel_##{turn.game.uuid}", 
      channel: "game_channel_##{turn.game.uuid}", 
      type: "update_game",
      action: "UPDATE_GAME_OF_TURN",
      header: {},
      body: {
        game: GameSerializer.new(Game.get_for_turn(turn), game_serializer_options).serializable_hash,
        spawners: SpawnerSerializer.new(Spawner.get_for_turn(turn), spawners_serializer_options).serializable_hash,
        units: UnitSerializer.new(Unit.get_for_turn(turn), unit_serializer_options).serializable_hash,
        turn: TurnSerializer.new(turn, turn_serializer_options).serializable_hash
      }
    )
  end

  def self.init_game(game)
    game_serializer_options = { 
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
          :host_user,
          :turn_count,
          :map_state
        ]
      } 
    }

    spawners_serializer_options = { 
      fields: { 
        spawner: [
          :active,
          :colour, 
          :skill_points, 
          :passed_initial_test, 
          :error, 
          :cancelled, 
          :error_history_array, 
          :spawner_name
        ]
      } 
    }

    unit_serializer_options = { 
      fields: { 
        unit: [
          :uuid, 
          :attribute_health, 
          :coordinate_Y, 
          :coordinate_X, 
          :base_health, 
          :base_movement, 
          :base_range, 
          :base_melee, 
          :base_vision,
          :base_spawn_position,
          :data_set, 
          :error_history_array, 
          :movement_history, 
          :colour, 
          :unit_output_history_array, 
          :active, 
          :new,
          :error, 
          :cancelled,
          :current_path,
          :target_coordinate_string,
          :path_step_count,
          :obstacle
        ]
      } 
    }

    ActionCable.server.broadcast("game_channel_##{game.uuid}", 
      channel: "game_channel_##{game.uuid}", 
      type: "update_game",
      action: "INIT_GAME",
      header: {},
      body: {
        game: GameSerializer.new(game, game_serializer_options).serializable_hash,
        spawners: SpawnerSerializer.new(game.spawners, spawners_serializer_options).serializable_hash,
        units: UnitSerializer.new(game.units, unit_serializer_options).serializable_hash,
      }
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