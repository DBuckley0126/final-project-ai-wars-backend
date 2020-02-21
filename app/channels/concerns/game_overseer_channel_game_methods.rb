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

    TurnMachine.new_turn(user, found_game, turn_payload)

  end
end