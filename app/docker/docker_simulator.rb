require_relative './process_turn_machine'

module DockerSimulator
  def self.new(docker_arg)
    docker = fork {
      ProcessTurnMachine.new_turn(docker_arg)
      puts "--------------------------------------------------------"
      puts "//////////////////////////////////////////////////////////"
      puts "Docker Closing"
      exit
    }
  end
end
