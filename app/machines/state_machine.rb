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

    all_friendly_active_units = Unit.find_all_friendly_units(turn)

    all_enemy_active_units = Unit.find_all_enemy_units(turn)

    all_friendly_active_units.each do |unit|
      if unit.new
        StateMachine.process_new_unit_state(unit)
      end
      StateMachine.process_unit_movement(unit, turn)
    end
  end

  def self.process_new_unit_state(unit)
    unit.coordinate_Y = rand(1..50)
    unit.coordinate_X = 1
    unit.attribute_health = unit.spawner.skill_points["health"]
    unit.base_health = unit.spawner.skill_points["health"]
    unit.base_melee = unit.spawner.skill_points["melee"]
    unit.base_vision = unit.spawner.skill_points["vision"]
    unit.base_range = unit.spawner.skill_points["range"]
    unit.base_movement = unit.spawner.skill_points["movement"]
    unit.new = false
    unit.save
  end

  def self.process_unit_movement(unit, turn)
    found_unit_output = unit.unit_output_history_array.find { |unit_output| unit_output["turn_count"] === turn.turn_count }
    
    movement_array = []

    if found_unit_output && 
      found_unit_output["output"]["movement"] && 
      found_unit_output["output"]["movement"]["target"] && 
      found_unit_output["output"]["movement"]["target"]["X"].is_a?(Integer) &&
      found_unit_output["output"]["movement"]["target"]["Y"].is_a?(Integer)

      target_X = found_unit_output["output"]["movement"]["target"]["X"]
      target_Y = found_unit_output["output"]["movement"]["target"]["Y"]
      current_X = unit.coordinate_X
      current_Y = unit.coordinate_Y

      movement_limit = unit.base_movement

      if target_X && target_Y && current_X && current_Y
        #Begin movement
        movement_limit.times do |i|
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
          # Add current location to movement array
          movement_array << {X: current_X, Y: current_Y}
        end
        #End of movement loop
        unit.coordinate_X = current_X
        unit.coordinate_Y = current_Y
      end

    end
    unit.movement_history_array << {turn_count: turn.turn_count, movements: movement_array}
    unit.save
  end

end