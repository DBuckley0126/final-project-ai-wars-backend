require_relative './test_machine'
require_relative './state_machine'
require_relative './docker_machine'
module TurnMachine
  def self.new_turn(user, game, turn_payload)
    # turn_uuid = rand(100000000..999999999)
    turn_uuid = 876475896
    new_turn = Turn.create(user: user, game: game, user_turn_payload: turn_payload, uuid: turn_uuid)
    Spawner.attempt_create(user, game, turn_payload)
    StateMachine.before_state_compiler(user, game, new_turn)
    TurnMachine.execute_docker(new_turn)
  end

  def self.after_turn()
    StateMachine.after_state_compiler(user, game)
  end

  def self.execute_docker(new_turn)
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_external_lib
    # For now will be default arg 876475896
    docker_arg = new_turn.uuid
    require_relative '../docker/docker_exec.rb'
  end
end
