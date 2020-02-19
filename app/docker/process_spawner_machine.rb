require_relative './docker_test_machine'
require 'yaml'

module ProcessSpawnerMachine
  def self.new_process(json_spawner)
    reader, writer = IO.pipe

    spawner_fork = fork do
      reader.close

      spawner_error_array = []

      # Creates class file from security checked string
      if json_spawner["attributes"]["passed_initial_test"] && !json_spawner["attributes"]["cancelled"]
        randomUUID = Random.new_seed
        File.open("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb", "w"){|file| file.puts json_spawner["attributes"]["code_string"]}

        # Attempts load of created file
        begin
          require_relative "temp_spawner_classes/spawner_class##{randomUUID}PIXELING"
        rescue ScriptError => error
          captured_error = ProcessSpawnerMachine.print_syntax_exception(error, true)

          File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
          
          yaml_hash = YAML.dump({processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "Syntax Error", message: captured_error, payload: nil}]})
          writer.write(yaml_hash)
          exit
        end

      else
        File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
        yaml_hash = YAML.dump({processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "Spawner has not executed", message: "Spawner has not passed initial tests or has been canceled internally", payload: nil}]})
        writer.write(yaml_hash)
        exit
      end

      # Loads marshalled units into Objects and puts them into arrays with additional attributes
      begin
      unit_object_array = json_spawner["attributes"]["units"].map { |unit|
          if unit.active
            loaded_unit = Marshal.load(unit["marshal_string"])
            return {uuid: unit["uuid"], object: loaded_unit, data_set: unit["data_set"], errors: [], new: false}
          end
        }
      rescue StandardError => error
        File.delete("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb") if File.exist?("app/docker/temp_spawner_classes/spawner_class##{randomUUID}PIXELING.rb")
        yaml_hash = YAML.dump({processed_units: [], spawner_errors:[{test_results: "FAIL", error_type: "SEVER_ERROR: Spawner has not executed", message: "Unable to load all unit marshal strings", payload: nil}]})
        writer.write(yaml_hash)
        exit
      end

      # Attempt to create new unit from spawner
      new_unit_result = ProcessSpawnerMachine.get_new_unit_output()

       # Add new unit to array if results was "PASS"
      if new_unit_result[:test_results] === "FAIL"
        spawner_error_array << new_unit_result
      else
        unit_object_array << {uuid: Random.new_seed, object: new_unit_result[:payload], data_set: {}, errors: [], new: true}
      end

      # Process units to produce their outputs, Completing Marshal.dump on object
      processed_unit_object_array = unit_object_array.map { |unit| 
        ProcessSpawnerMachine.process_unit(unit)
      }

      ## Outputs processed_units + spawner errors to IO.Pipe
      yaml_hash = YAML.dump({processed_units: processed_unit_object_array, spawner_errors: spawner_error_array}) 

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
    complete_object_return = {
      health: {},
      melee: {},
      range: {},
      vision: {},
      movement: {}
    }

    unit_error_array = []

    begin
      if object.respond_to? :set_payload_data
        object.set_payload_data(unit[:data_set])
      end

      if object.respond_to? :movement
        test_results = DockerTestMachine.unit_movement_test(object.movement())
        complete_object_return[:movement] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :melee
        test_results = DockerTestMachine.unit_melee_test(object.melee())
        complete_object_return[:melee] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :range
        test_results = DockerTestMachine.unit_range_test(object.range())
        complete_object_return[:range] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :vision
        test_results = DockerTestMachine.unit_vision_test(object.vision())
        complete_object_return[:vision] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end

      if object.respond_to? :health
        test_results = DockerTestMachine.unit_health_test(object.health())
        complete_object_return[:health] = test_results[:hash_payload]
        # Add test errors to unit array if any
        test_results[:error_payload].each { |error| unit_error_array << error }
      end
    rescue NameError => error
      error_message = ProcessSpawnerMachine.print_name_exception(error, true)
      return {uuid: unit[:uuid], object: Marshal.dump(object), new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: error_message}]}
    
    rescue ArgumentError => error
      error_message = ProcessSpawnerMachine.print_argument_exception(error, true)
      return {uuid: unit[:uuid], object: Marshal.dump(object), new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: error_message}]}
    
    rescue StandardError => error
      return {uuid: unit[:uuid], object: Marshal.dump(object), new: unit[:new], errors: [{completed_cycle: false, error_type: "FAIL", error_message: "Issue calling methods on unit"}]}
    
    end

    return {uuid: unit[:uuid], object: Marshal.dump(object), new: unit[:new], errors: unit_error_array}
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