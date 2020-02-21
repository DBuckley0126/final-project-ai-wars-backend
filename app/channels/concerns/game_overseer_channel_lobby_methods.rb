require_relative '../broadcast_actions/cable_helper_actions.rb'

module GameOverseerChannelLobbyMethods
  def subscribed

    if !connection.user || !params["game_uuid"] || !params["request_type"]
      reject
    end

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

    if params["request_type"] === "JOIN_LOBBY"
      # COMPLETE JOIN LOBBY REQUEST

      found_game = Game.find_by(uuid: params["game_uuid"])
    
      if found_game 
        ready_lobby = found_game.add_user(connection.user)
      end
  
      if ready_lobby
        stream_from "game_channel_##{ready_lobby.uuid}"
        stream_from "game_channel_##{ready_lobby.uuid}_for_user_##{connection.user.sub}"
  
        ActionCable.server.broadcast("game_channel_##{ready_lobby.uuid}_for_user_##{connection.user.sub}", 
          channel: "game_channel_##{ready_lobby.uuid}_for_user_##{connection.user.sub}", 
          type: "subscribed",
          action: "SUCCESSFULLY_SUBSCRIBED_TO_GAME",
          header: {},
          body: {game_uuid: ready_lobby.uuid}
        )

        CableHelperActions.update_game_lobby(ready_lobby)
  
      else
        reject
      end

    elsif params["request_type"] === "CREATE_LOBBY"
      # COMPLETE CREATE LOBBY REQUEST

      created_lobby = Game.create(uuid: params["game_uuid"], host_user: connection.user)

      if created_lobby
        stream_from "game_channel_##{created_lobby.uuid}"
        stream_from "game_channel_##{created_lobby.uuid}_for_user_##{connection.user.sub}"

        ActionCable.server.broadcast("game_channel_##{created_lobby.uuid}_for_user_##{connection.user.sub}", 
          channel: "game_channel_##{created_lobby.uuid}_for_user_##{connection.user.sub}", 
          type: "subscribed",
          action: "SUCCESSFULLY_SUBSCRIBED_TO_GAME",
          header: {},
          body: {game_uuid: created_lobby.uuid}
        )
  
        CableHelperActions.update_game_lobby(created_lobby)

      else
        reject
      end

    else
    end
    CableHelperActions.update_game_instances()
  end

  def update_user_lobby_status(payload)
    user = connection.user
    found_lobby = Game.find_by(uuid: params["game_uuid"])

    if !found_lobby || !user
      return
    end

    if payload["readyStatus"]
      if found_lobby.host_user === user
        if payload["readyStatus"] === "TOGGLE"
          found_lobby.host_user_ready = !found_lobby.host_user_ready
        else
          found_lobby.host_user_ready = payload["readyStatus"]
        end
        
      elsif found_lobby.join_user === user
        if payload["readyStatus"] === "TOGGLE"
          found_lobby.join_user_ready = !found_lobby.join_user_ready
        else
          found_lobby.join_user_ready = payload["readyStatus"]
        end
        
      end
      found_lobby.save

      CableHelperActions.update_game_lobby(found_lobby)
    end

  end

  def start_game_request
    user = connection.user
    found_lobby = Game.find_by(uuid: params["game_uuid"])

    if !found_lobby || !user
      return
    end

    #TEMPORARY CHANGE TO JOIN_USER, CHANGE BACK!!!
    if found_lobby.host_user_ready && found_lobby.join_user_ready && found_lobby.join_user === user
      found_lobby.game_initiated = true
      found_lobby.status = "IN_GAME"
      found_lobby.save

      ActionCable.server.broadcast("game_channel_##{found_lobby.uuid}", 
        channel: "game_channel_##{found_lobby.uuid}", 
        type: "start_game",
        action: "START_GAME",
        header: {},
        body: {}
      )

      CableHelperActions.update_game_instances()
    else 
      return
    end
  end

  def unsubscribed
    user = connection.user
    found_lobby = Game.find_by(uuid: params["game_uuid"])

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

    if found_lobby && found_lobby.game_initiated
        found_lobby.status = "CANCELED_GAME"
        # TEST PURPOSES DELETE AFTER
        found_lobby.status = "LOBBY"
        found_lobby.join_user = nil
        found_lobby.join_user_type = nil
        found_lobby.game_initiated = false
        #DELETE BETWEEN
        found_lobby.save

        if found_lobby && found_lobby.host_user === user
          user_type_left = "Host"
        elsif found_lobby && found_lobby.join_user === user
          user_type_left = "Join user"
        else
          user_type_left = "Unknown"
        end

  
        ActionCable.server.broadcast("game_channel_##{found_lobby.uuid}", 
          channel: "game_channel_##{found_lobby.uuid}",
          type: "unsubscribed",
          action: "CANCEL_LOBBY",
          header: {reason: "#{user_type_left} left the game"},
          body: GameSerializer.new(found_lobby, serializerOptions).serializable_hash
        )

      CableHelperActions.update_game_lobby(found_lobby)

    else
      if found_lobby && found_lobby.host_user === user
        found_lobby.status = "CANCELED_LOBBY"
        found_lobby.host_user_ready = false
        found_lobby.join_user_ready = false
        found_lobby.save
  
        ActionCable.server.broadcast("game_channel_##{found_lobby.uuid}", 
          channel: "game_channel_##{found_lobby.uuid}",
          type: "unsubscribed",
          action: "CANCEL_LOBBY",
          header: {reason: "Host left the lobby"},
          body: GameSerializer.new(found_lobby, serializerOptions).serializable_hash
        )
  
      elsif found_lobby && found_lobby.join_user === user
        found_lobby.join_user = nil
        found_lobby.host_user_ready = false
        found_lobby.join_user_ready = false
        found_lobby.save
        CableHelperActions.update_game_lobby(found_lobby)
      end

      CableHelperActions.update_game_instances()
    end
  end
end