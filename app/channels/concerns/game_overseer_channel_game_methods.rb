require_relative '../broadcast_actions/cable_helper_actions.rb'
require_relative '../../machines/turn_machine.rb'


module GameOverseerChannelGameMethods
  
  def init_player_turn(payload)
    user = connection.user
    found_lobby = Game.find_by(uuid: params["game_uuid"])
    turn_payload = payload

    if !found_lobby || !user || !payload
      return
    end

    TurnMachine.new_turn(user, found_lobby, turn_payload)

  end
end