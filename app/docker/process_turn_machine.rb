require_relative './process_spawner_machine'
module ProcessTurnMachine

  def self.new_turn
    input_hash = JSON.load(File.read("app/docker_external_lib/docker_input.json"))
    input_hash["data"].each do |json_spawner|
     hash =  ProcessSpawnerMachine.new_process(json_spawner)
      binding.pry
    end

  end
end