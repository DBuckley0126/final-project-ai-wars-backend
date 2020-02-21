require_relative './process_spawner_machine'
module ProcessTurnMachine

  def self.new_turn(temp_docker_arg)
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_input_external_lib
    # For now will be default arg 876475896

    input_hash = JSON.load(File.read("app/docker_input_external_lib/docker_input##{temp_docker_arg}.json"))
    collected_spawner_outputs = input_hash["data"].map do |json_spawner|
     ProcessSpawnerMachine.new_process(json_spawner)
    end
    ProcessTurnMachine.package_turn_output(collected_spawner_outputs, temp_docker_arg)
    ProcessTurnMachine.close_docker_container(temp_docker_arg)
  end

  def self.package_turn_output(contents, temp_docker_arg)
    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_output_external_lib
    # For now will be default arg 876475896

    json = {data: contents}.to_json
    File.open("app/docker_output_external_lib/docker_output##{temp_docker_arg}.json", "w"){|file| file.puts json}
  end

  def self.close_docker_container(temp_docker_arg)
    #Alternative code once docker is implemented
    File.delete("app/docker_input_external_lib/docker_input##{temp_docker_arg}.json") if File.exist?("app/docker_input_external_lib/docker_input##{temp_docker_arg}.json")

  end
end