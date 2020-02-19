require 'json'
module StateMachine
  def self.before_state_compiler(user, game)
    related_spawners = Spawner.where(user: user, game: game)
    json = SpawnerSerializer.new(related_spawners).serialized_json

    File.open('app/docker_external_lib/docker_input.json', "w"){|file| file.puts json}
  end

  def self.after_state_compiler

  end
end