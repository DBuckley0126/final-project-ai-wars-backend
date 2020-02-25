require_relative './docker_test_machine'
require 'yaml'

module ProcessSpawnerMachine
  def self.new_process(json_spawner)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "#{json_spawner["id"]} is starting to process"
    reader, writer = IO.pipe

    spawner_fork = fork do
      reader.close

      spawner_error_array = []
      # Creates class file from security checked string
      if json_spawner["attributes"]["passed_initial_test"] && !json_spawner["attributes"]["cancelled"]
        randomUUID = rand(1000000..9999999)
        File.open("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb", "w"){|file| file.puts json_spawner["attributes"]["code_string"]}
        puts "///////////////////////////////////////////////////////"
        puts "sucessfully created file from spawner string!"
        puts "////////////////////////////////////////////////////////"
        # Attempts load of created file
        begin
          require_relative "temp_spawner_classes/spawner_class##{randomUUID}PIXELING"
          puts "///////////////////////////////////////////////////////"
          puts "sucessfully loaded file!"
          puts "////////////////////////////////////////////////////////"
        rescue ScriptError => error
          captured_error = ProcessSpawnerMachine.print_syntax_exception(error, true)

          File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
          
          yaml_hash = YAML.dump({id: json_spawner["id"], processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "Syntax Error", message: captured_error, payload: nil}]})
          writer.write(yaml_hash)
          exit
        end

      else
        File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
        yaml_hash = YAML.dump({id: json_spawner["id"], processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "Spawner has not executed", message: "Spawner has not passed initial tests or has been canceled internally", payload: nil}]})
        writer.write(yaml_hash)
        exit
      end

      # Loads marshalled units into Objects and puts them into arrays with additional attributes
      begin
        puts "///////////////////////////////////////////////////////"
        puts "Begin loading units from marshal objects!"
        puts "////////////////////////////////////////////////////////"
      unit_object_array = json_spawner["attributes"]["units"].map { |unit|
          if unit["active"]
            loaded_unit = Marshal.load(unit["marshal_object"])
            {uuid: unit["uuid"], spawner_id: unit["spawner_id"] ,object: loaded_unit, data_set: unit["data_set"], errors: [], new: false, colour: unit["colour"]}
          end
        }
      rescue StandardError => error
        File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
        yaml_hash = YAML.dump({id: json_spawner["id"], processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "SEVER_ERROR: Spawner has not executed", message: "Unable to load all unit marshal strings", payload: nil}]})
        writer.write(yaml_hash)
        exit
      end
      puts "///////////////////////////////////////////////////////"
      puts "Sucessfully loaded units from marshal objects!#{unit_object_array}"
      puts "////////////////////////////////////////////////////////"

      # Attempt to create new unit from spawner if spawner still active
      if json_spawner["attributes"]["active"]
        new_unit_result = ProcessSpawnerMachine.get_new_unit_output()
      else
        new_unit_result = nil
      end
      puts "///////////////////////////////////////////////////////"
      puts "Sucessfully created new unit from marshal objects!#{new_unit_result}"
      puts "////////////////////////////////////////////////////////"

       # Add new unit to array if results was "PASS" and spawner was active
      if new_unit_result && new_unit_result[:test_results] === "FAIL"
        spawner_error_array << new_unit_result
      else 
        unit_object_array << {uuid: rand(1000000000..9999999999), spawner_id: json_spawner["id"], object: new_unit_result[:payload], data_set: {}, errors: [], new: true, colour: json_spawner["attributes"]["colour"]}
      end

      puts "///////////////////////////////////////////////////////"
      puts "Sucessfully added new unit to main array!#{unit_object_array}"
      puts "////////////////////////////////////////////////////////"

      # Process units to produce their outputs
      processed_unit_object_array = unit_object_array.map { |unit| 
        ProcessSpawnerMachine.process_unit(unit)
      }

      puts "///////////////////////////////////////////////////////"
      puts "Sucessfully processed units for outputs!#{processed_unit_object_array}"
      puts "////////////////////////////////////////////////////////"

      ## Outputs processed_units + spawner errors to IO.Pipe
      yaml_hash = YAML.dump({id: json_spawner["id"], processed_units: processed_unit_object_array, spawner_errors: spawner_error_array}) 

      puts "///////////////////////////////////////////////////////"
      puts "Sucessfully created YMAL hash"
      puts "////////////////////////////////////////////////////////"
      writer.write(yaml_hash)
      File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
      exit
      
    end

    Process.wait(spawner_fork)
    writer.close

    converted_hash = YAML.load(reader.read)

    return converted_hash

  end


  def self.get_new_unit_output()
    begin
    initial_unit = Pixeling.new
    if !initial_unit.is_a?(Pixeling)
      StandardError.new("This spawner does not contain a class called Pixeling")
    end
    rescue StandardError => error
      return {test_results: "FAIL", error_type: "Failed to create Pixeling", message: error.message, payload: nil}
    end
    return {test_results: "PASS", error_type: nil, message: nil, payload: initial_unit}
  end


  def self.process_unit(unit)
    object = unit[:object]

    complete_unit_return = {
      health: {},
      melee: {},
      range: {},
      vision: {},
      movement: {},
      spawn_position: {}
    }

    # For sending back when exception is rescued
    empty_unit_return = {
      health: {},
      melee: {},
      range: {},
      vision: {},
      movement: {},
      spawn_position: {}
    }

    unit_error_array = []

    begin
      if object.respond_to? :set_payload_data
        object.set_payload_data(unit[:data_set])
      end

      if object.respond_to? :movement
        test_results = DockerTestMachine.unit_movement_test(object.movement())
        complete_unit_return[:movement] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :spawn_position
        test_results = DockerTestMachine.unit_spawn_position_test(object.spawn_position())
        complete_unit_return[:spawn_position] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :melee
        test_results = DockerTestMachine.unit_melee_test(object.melee())
        complete_unit_return[:melee] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :range
        test_results = DockerTestMachine.unit_range_test(object.range())
        complete_unit_return[:range] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :vision
        test_results = DockerTestMachine.unit_vision_test(object.vision())
        complete_unit_return[:vision] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :health
        test_results = DockerTestMachine.unit_health_test(object.health())
        complete_unit_return[:health] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

    rescue NameError => error
      error_message = ProcessSpawnerMachine.print_name_exception(error, true)
      return {uuid: unit[:uuid], latest_unit_output: empty_unit_return, marshal_object: Marshal.dump(object), spawner_id: unit[:spawner_id], colour: unit[:colour], new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: error_message}]}
    
    rescue ArgumentError => error
      error_message = ProcessSpawnerMachine.print_argument_exception(error, true)
      return {uuid: unit[:uuid], latest_unit_output: empty_unit_return, marshal_object: Marshal.dump(object), spawner_id: unit[:spawner_id], colour: unit[:colour], new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: error_message}]}
    
    rescue StandardError => error
      return {uuid: unit[:uuid], latest_unit_output: empty_unit_return, marshal_object: Marshal.dump(object), spawner_id: unit[:spawner_id], colour: unit[:colour], new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: "Issue calling methods on unit"}]}
    end

    return {uuid: unit[:uuid], latest_unit_output: complete_unit_return, marshal_object: Marshal.dump(object), spawner_id: unit[:spawner_id], colour: unit[:colour], new: unit[:new], errors: unit_error_array}
  end

  def self.print_syntax_exception(exception, explicit)
    error_string = "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
    first_part_removed_string = error_string.gsub(/\/.*PIXELING/, "pixeling")
    first_and_last_parts_removed = first_part_removed_string.gsub(/\/Users\/dannybuckley.*PIXELING/, "pixeling")
  end

  def self.print_name_exception(exception, explicit)
    error_string = "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
    last_part_removed_string = error_string.gsub(/for\s#<Pixeling:.*>/, "")
  end

  def self.print_argument_exception(exception, explicit)
    error_string = "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
    last_part_removed_string = error_string.gsub(/for\s#<Pixeling:.*>/, "")
  end

end