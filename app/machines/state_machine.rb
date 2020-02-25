require 'json'
require_relative './database_input_machine.rb'
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
    game = turn.game
    user = turn.game
    current_map_state = game.map_state

    all_friendly_active_units = Unit.find_all_friendly_units(turn)

    all_enemy_active_units = Unit.find_all_enemy_units(turn)

    all_friendly_active_units.each do |unit|
      if unit.new
        StateMachine.process_new_unit_state(unit)
      end
    end
    
    11.times do |step_number|
      returned_map_state = StateMachine.process_step(all_friendly_active_units, turn, step_number, current_map_state)
      current_map_state = returned_map_state
      turn.map_states_for_turn[step_number] = Game.game_state_to_array(returned_map_state)
    end

    game.map_state = current_map_state

    turn.save
    game.save
  end

  def self.process_new_unit_state(unit)
    unit.attribute_health = unit.spawner.skill_points["health"]
    unit.base_health = unit.spawner.skill_points["health"]
    unit.base_melee = unit.spawner.skill_points["melee"]
    unit.base_vision = unit.spawner.skill_points["vision"]
    unit.base_range = unit.spawner.skill_points["range"]
    unit.base_movement = unit.spawner.skill_points["movement"]
    unit.coordinate_X = 1

    found_unit_output = unit.unit_output_history_array.first
    if found_unit_output && found_unit_output["output"]["spawn_position"] && found_unit_output["output"]["spawn_position"]["Y"] && found_unit_output["output"]["spawn_position"]["Y"].is_a?(Integer)
      unit.base_spawn_position = found_unit_output["output"]["spawn_position"]["Y"]
      unit.coordinate_Y = unit.base_spawn_position
    else
      unit.base_spawn_position = nil
      unit.coordinate_Y = rand(1..50)
    end
    
    unit.new = false
    unit.save
  end

  def self.process_step(freindly_units, turn, step_number, map_state)
    # complete path finding of unit if under movement limit

    if step_number === 0
      freindly_units.each do |unit|
        map_state = StateMachine.process_unit_initial_positions(unit, turn, map_state)
      end
    else
      freindly_units.each do |unit|
        if step_number <= unit.base_movement
          map_state = StateMachine.process_unit_movement(unit, turn, map_state)
        end
      end
    end

    map_state
  end

  def self.process_unit_movement(unit, turn, map_state)
    found_unit_output = unit.unit_output_history_array.find { |unit_output| unit_output["turn_count"] === turn.turn_count }
    

    # Does basic checks on unit desired movement output
    if found_unit_output && 
      found_unit_output["output"]["movement"] && 
      found_unit_output["output"]["movement"]["target"] && 
      found_unit_output["output"]["movement"]["target"]["X"].is_a?(Integer) &&
      found_unit_output["output"]["movement"]["target"]["Y"].is_a?(Integer)

      target_X = found_unit_output["output"]["movement"]["target"]["X"]
      target_Y = found_unit_output["output"]["movement"]["target"]["Y"]
      current_X = unit.coordinate_X
      current_Y = unit.coordinate_Y

      if target_X && target_Y && current_X && current_Y
        #Begin movement

        #Check if arrived at target_X
        if current_X != target_X
          #Checks if target is higher or lower than current
          if current_X < target_X
            current_X = current_X + 1
          end
          if current_X > target_X
            current_X = current_X - 1
          end
        end

        #Check if arrived at target_Y
        if current_Y != target_Y
          #Checks if target is higher or lower than current
          if current_Y < target_Y
            current_Y = current_Y + 1
          end
          if current_Y > target_Y
            current_Y = current_Y - 1
          end
        end

        map_state[unit.string_coordinates] = nil

        unit.coordinate_X = current_X
        unit.coordinate_Y = current_Y

        map_state[unit.string_coordinates] = unit.uuid
      end
    end

    if unit.movement_history[turn.turn_count.to_s]
      unit.movement_history[turn.turn_count.to_s] << {X: unit.coordinate_X , Y: unit.coordinate_Y}
    else
      unit.movement_history[turn.turn_count.to_s] = [{X: unit.coordinate_X , Y: unit.coordinate_Y}]
    end

    unit.save

    map_state
  end

  def self.process_unit_initial_positions(unit, turn, map_state)
    map_state[unit.string_coordinates] = unit.uuid

    if unit.movement_history[turn.turn_count.to_s]
      unit.movement_history[turn.turn_count.to_s] << {X: unit.coordinate_X , Y: unit.coordinate_Y}
    else
      unit.movement_history[turn.turn_count.to_s] = [{X: unit.coordinate_X , Y: unit.coordinate_Y}]
    end

    unit.save

    map_state
  end

end