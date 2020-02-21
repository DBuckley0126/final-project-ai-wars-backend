require_relative './test_machine'
require_relative './state_machine'
require_relative './docker_machine'
require_relative '../channels/broadcast_actions'
require_relative '../docker/docker_simulator'
module TurnMachine
  def self.new_turn(user, game, turn_payload)
    turn_uuid = rand(100000000..999999999)

    # turn_uuid = 876475896
    game.increase_turn_count()
    new_turn = Turn.create(user: user, game: game, user_turn_payload: turn_payload, uuid: turn_uuid, turn_count: game.turn_count)
    Spawner.attempt_create(user, game, turn_payload)
    StateMachine.before_state_compiler(user, game, new_turn)
    TurnMachine.execute_docker(new_turn)
    TurnMachine.init_file_check_loop(new_turn)
  end

  def self.after_turn(turn_uuid)
    found_turn = Turn.find_by(uuid: turn_uuid)
    if found_turn
      StateMachine.after_state_compiler(found_turn)
      StateMachine.game_state_processor(found_turn)
      CableHelperActions.update_game_of_turn(found_turn)
      # CableHelperActions.update_game_instances
    else
      puts "SERVER_ERROR: UNABLE TO FIND TURN"
    end
  end

  def self.execute_docker(new_turn)
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_external_lib
    # For now will be default arg 876475896

    temp_docker_arg = new_turn.uuid
    #tempary_docker_simulator
    DockerSimulator.new(temp_docker_arg)
  end

  def self.init_file_check_loop(turn)
    while !File.exist?("app/docker_output_external_lib/docker_output##{turn.uuid}.json")
      sleep 0.2
    end
    puts "---------------------------------------------"
    puts "FOUND FILE ON FORK"
    TurnMachine.after_turn(turn.uuid)
  end


end