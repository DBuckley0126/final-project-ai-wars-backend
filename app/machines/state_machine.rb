require 'json'
require_relative './database_input_machine.rb'
require_relative './path_finder_machine.rb'
require_relative './movement_machine.rb'
require_relative './melee_machine.rb'
require_relative './payload_machine'

module StateMachine
  def self.before_state_compiler(user, game, turn)
    
    all_friendly_active_units = Unit.find_all_friendly_units(turn)

    # Process unit payloads if active
    all_friendly_active_units.each do |unit|
      PayloadMachine.add_payload(turn, unit)
    end

    related_spawners = Spawner.where(user: user, game: game)

    related_spawners.each do |spawner|
      PayloadMachine.add_general_payload(turn, spawner)
    end

    json = SpawnerSerializer.new(related_spawners).serialized_json

    # A docker ARG variable will be inserted into the .new_turn method as an agument.
    # This references what files to grab from the docker_input_external_lib
    # For now will be default arg 876475896
    default_temp_arg = turn.uuid
    File.open("app/docker_input_external_lib/docker_input##{default_temp_arg}.json", "w"){|file| file.puts json}
  end

  def self.after_state_compiler(turn)
    json_object = JSON.load(File.read("app/docker_output_external_lib/docker_output##{turn.uuid}.json"))

    if json_object["data"]
      DatabaseInputMachine.save_after_state_results(json_object["data"], turn)
    else
      puts "FATAL ERROR - UNABLE TO LOAD JSON OUTPUT DATA FROM DOCKER"
    end

    File.delete("app/docker_output_external_lib/docker_output##{turn.uuid}.json") if File.exist?("app/docker_output_external_lib/docker_output##{turn.uuid}.json")
  end

  def self.game_state_processor(turn)

    # Get latest friendly active units
    all_friendly_active_units = Unit.find_all_friendly_units(turn)

    # Process new units state
    all_friendly_active_units.each do |unit|
      if unit.new
        StateMachine.process_new_unit_state(unit, turn)
      end
    end
    
    MovementMachine.process_units_position_action(turn)
    MeleeMachine.process_units_melee_action(turn)
    StateMachine.check_for_win(turn)

    # Check all processed units for errors
    all_friendly_active_units.each do |unit|
      unit.check_for_warning_errors_for_turn()
      unit.check_for_fatal_errors_for_turn()
    end


    Unit.save_collection(all_friendly_active_units)
    turn.save
    turn.game.save
  end

  def self.check_for_win(turn)
    map_state = turn.game.map_state
    host_user = turn.game.host_user
    join_user = turn.game.join_user

    if turn.game.join_user === turn.user
      user_type = "join_user"
    else
      user_type = "host_user"
    end

    friendly_units = Unit.find_all_friendly_units(turn)

    friendly_units.each do |unit|
      xy_hash = MapMachine.convert_string_to_coordinate_xy(unit.string_coordinates)
      if user_type === "host_user"
        if xy_hash[:x] === 50
          if map_state[unit.string_coordinates]["contents"] && map_state[unit.string_coordinates]["contents"] === unit.uuid
            StateMachine.complete_winning_state(turn, host_user, join_user)
          end
        end
      end
      if user_type === "join_user"
        if xy_hash[:x] === 1
          if map_state[unit.string_coordinates]["contents"] && map_state[unit.string_coordinates]["contents"] === unit.uuid
            StateMachine.complete_winning_state(turn, join_user, host_user)
          end
        end
      end
    end

  end

  def self.complete_winning_state(turn, winning_user, loosing_user)
    game = turn.game
    turn.winning_turn = true
    game.winner_user_sub = winning_user.sub
    game.status = "COMPLETE"
    winning_user.add_win()
    loosing_user.add_loss()
  end

  def self.process_new_unit_state(unit, turn)
    map_state = turn.game.map_state

    unit.attribute_health = unit.spawner.skill_points["health"]
    unit.base_health = unit.spawner.skill_points["health"]
    unit.base_melee = unit.spawner.skill_points["melee"]
    unit.base_vision = unit.spawner.skill_points["vision"]
    unit.base_range = unit.spawner.skill_points["range"]
    unit.base_movement = unit.spawner.skill_points["movement"]

    # Decides which side of the map to spawn on
    if unit.user_type == "host_user"
      unit.coordinate_X = 3
    else
      unit.coordinate_X = 48
    end
    
    found_unit_output = unit.unit_output_history_array.first
    if found_unit_output && found_unit_output["output"]["spawn_position"] && found_unit_output["output"]["spawn_position"]["Y"] && found_unit_output["output"]["spawn_position"]["Y"].is_a?(Integer)
      unit.coordinate_Y = found_unit_output["output"]["spawn_position"]["Y"]
      unit.base_spawn_position = unit.string_coordinates

      # If target spawn position taken, find closest one, if none available, cancel unit

      if map_state[unit.string_coordinates]["contents"]

        closest_available_position = MapMachine.closest_available_y(map_state, unit.string_coordinates)

        if closest_available_position
          xy_hash = MapMachine.convert_string_to_coordinate_xy(closest_available_position)
          unit.coordinate_X = xy_hash[:x]
          unit.coordinate_Y = xy_hash[:y]
          MapMachine.update_position(map_state, unit.string_coordinates, unit.uuid)
          unit.add_error_for_turn({completed_cycle: true, error_type: "WARNING", error_message: "Target spawn position was not available"})
        else
          unit.base_spawn_position = nil
          unit.coordinate_X = nil
          unit.coordinate_Y = nil
          unit.error = true
          unit.cancelled = true
          unit.active = false
          unit.add_error_for_turn({completed_cycle: false, error_type: "CRITICAL", error_message: "No spawn positions was not available"})
        end

      # Target spawn position availiable, add to map
      else
        MapMachine.update_position(map_state, unit.string_coordinates, unit.uuid)
      end
    else
      # No target spawn position returned, pick random one, if all positions taken up
      unit.base_spawn_position = nil
      available_position = MapMachine.any_available_y(map_state, unit.coordinate_X)

      if available_position
        xy_hash = MapMachine.convert_string_to_coordinate_xy(available_position)
        unit.coordinate_X = xy_hash[:x]
        unit.coordinate_Y = xy_hash[:y]
        MapMachine.update_position(map_state, unit.string_coordinates, unit.uuid)
      else
        unit.coordinate_X = nil
        unit.coordinate_Y = nil
        unit.error = true
        unit.cancelled = true
        unit.active = false
        unit.add_error_for_turn({completed_cycle: false, error_type: "CRITICAL", error_message: "No spawn positions was not available"})
      end
    end

    unit.new = false
    unit.save
  end

end