require_relative '../broadcast_actions/cable_helper_actions.rb'
require_relative '../../machines/turn_machine.rb'


module GameOverseerChannelGameMethods
  
  def init_player_turn(payload)
    user = connection.user
    found_game = Game.find_by(uuid: params["game_uuid"])
    turn_payload = payload

    if !found_game || !user || !payload
      return
    end

    if found_game.turn_count % 2 === 0 && found_game.join_user === user
      TurnMachine.new_turn(user, found_game, turn_payload)
    elsif found_game.turn_count % 2 != 0 && found_game.host_user === user
      TurnMachine.new_turn(user, found_game, turn_payload)
    end

  end
end