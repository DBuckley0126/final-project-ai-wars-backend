require_relative './process_spawner_machine'
module ProcessTurnMachine

  def self.new_turn
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_input_external_lib
    # For now will be default arg 876475896
    default_temp_arg = 876475896
    input_hash = JSON.load(File.read("app/docker_input_external_lib/docker_input##{default_temp_arg}.json"))
    collected_spawner_outputs = input_hash["data"].map do |json_spawner|
     ProcessSpawnerMachine.new_process(json_spawner)
    end
    ProcessTurnMachine.package_turn_output(collected_spawner_outputs)
    ProcessTurnMachine.close_docker_container()
  end

  def self.package_turn_output(contents)
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_output_external_lib
    # For now will be default arg 876475896
    default_temp_arg = 876475896
    json = {data: contents}.to_json
    File.open("app/docker_output_external_lib/docker_output##{default_temp_arg}.json", "w"){|file| file.puts json}
  end

  def self.close_docker_container
    #Alternative code once docker is implemented
  end
end