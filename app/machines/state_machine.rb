require 'json'
module StateMachine
  def self.before_state_compiler(user, game, turn)
    
    related_spawners = Spawner.where(user: user, game: game)
    json = SpawnerSerializer.new(related_spawners).serialized_json

    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_input_external_lib
    # For now will be default arg 876475896
    default_temp_arg = turn.uuid
    File.open("app/docker_input_external_lib/docker_input##{default_temp_arg}.json", "w"){|file| file.puts json}
  end

  def self.after_state_compiler

  end
end