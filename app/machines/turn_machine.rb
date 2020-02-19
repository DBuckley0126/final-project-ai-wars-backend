require_relative './test_machine'
require_relative './state_machine'
require_relative './docker_machine'
module TurnMachine
  def self.new_turn(user, game, turn_payload)
    Spawner.attempt_create(user, game, turn_payload)
    StateMachine.before_state_compiler(user, game)
    require_relative '../docker/docker_exec.rb'

  end
end
