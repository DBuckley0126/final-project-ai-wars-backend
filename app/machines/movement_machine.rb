require_relative './path_finder_machine.rb'

module MovementMachine

  def self.process_unit_positions(turn)
    all_friendly_active_units = Unit.find_all_friendly_units(turn)


    11.times do |step_number|
      MovementMachine.process_step(all_friendly_active_units, turn, step_number)
      turn.map_states_for_turn[step_number] = turn.game.map_state_to_array()
    end

    # Check all processed units for errors
    all_friendly_active_units.each do |unit|
      unit.check_for_warning_errors_for_turn()
      unit.check_for_fatal_errors_for_turn()
    end

    # Save all processed units
    Unit.save_collection(all_friendly_active_units)
    turn.save
    turn.game.save
  end

  def self.process_step(freindly_units, turn, step_number)
    # complete path finding of unit if under movement limit

    if step_number === 0
      freindly_units.each do |unit|
        MovementMachine.process_unit_initial_positions(unit, turn)
      end
      freindly_units.each do |unit|
        MovementMachine.process_unit_initial_path(unit, turn)
      end
    else
      freindly_units.each do |unit|
        if step_number <= unit.base_movement
          MovementMachine.process_unit_movement(unit, turn)
        end
      end
    end
  end

  def self.process_unit_movement(unit, turn)
    map_state = turn.game.map_state

    # Unit potential next position given from path
    next_string_coordinate = unit.current_path[unit.path_step_count]

    # Unit has path position to go to. If next_string_coordinate is nil, means unit is currently at destination or no path can be found to target
    if next_string_coordinate

      # Check if next position is taken up by any unit or obstacle
      while map_state[next_string_coordinate]["contents"] && unit.target_coordinate_string

        # Checks if target coordinate position is taken
        if map_state[unit.target_coordinate_string]["contents"]
          # Current target coordinate taken, find closest available new target
          unit.find_new_target(map_state)
          unit.current_path = PathFinderMachine.search(unit.string_coordinates, unit.target_coordinate_string, map_state)
          unit.path_step_count = 0
          next_string_coordinate = unit.current_path[unit.path_step_count]
          if !next_string_coordinate
            unit.movement_history[turn.turn_count.to_s] << {X: unit.coordinate_X , Y: unit.coordinate_Y}
            unit.path_step_count = 0
            return
          end
        else
          # Target position is available, find new path
          unit.current_path = PathFinderMachine.search(unit.string_coordinates, unit.target_coordinate_string, map_state)
          unit.path_step_count = 0
          next_string_coordinate = unit.current_path[unit.path_step_count]
          # If no new path found, add current position to unit movement history and exit
          if !next_string_coordinate
            unit.movement_history[turn.turn_count.to_s] << {X: unit.coordinate_X , Y: unit.coordinate_Y}
            unit.path_step_count = 0
            return
          end
        end

      end

      # Remove units current location from map
      MapMachine.update_position(map_state, unit.string_coordinates, nil)

      xy_hash = MapMachine.convert_string_to_coordinate_xy(next_string_coordinate)

      # Move unit to current location
      unit.coordinate_X = xy_hash[:x]
      unit.coordinate_Y = xy_hash[:y]

      MapMachine.update_position(map_state, unit.string_coordinates, unit.uuid)
    end

    unit.movement_history[turn.turn_count.to_s] << {X: unit.coordinate_X , Y: unit.coordinate_Y}
    unit.path_step_count += 1
  end

  def self.process_unit_initial_positions(unit, turn)
    map_state = turn.game.map_state
    MapMachine.update_position(map_state, unit.string_coordinates, unit.uuid)
    unit.movement_history[turn.turn_count.to_s] = [{X: unit.coordinate_X , Y: unit.coordinate_Y}]
  end

  def self.process_unit_initial_path(unit, turn)
    map_state = turn.game.map_state
    found_unit_output = unit.unit_output_history_array.find { |unit_output| unit_output["turn_count"] === turn.turn_count }

    if found_unit_output && 
      found_unit_output["output"]["movement"] && 
      found_unit_output["output"]["movement"]["target"] && 
      found_unit_output["output"]["movement"]["target"]["X"].is_a?(Integer) &&
      found_unit_output["output"]["movement"]["target"]["Y"].is_a?(Integer)

      target_X = found_unit_output["output"]["movement"]["target"]["X"]
      target_Y = found_unit_output["output"]["movement"]["target"]["Y"]

      unit.target_coordinate_string = MapMachine.convert_xy_to_coordinate_string(target_X, target_Y)

      # Checks if target coordinate position is taken
      if map_state[unit.target_coordinate_string]["contents"]
        puts "target coordinate taken!!!!!!!!!!!!!!!!!!!!!!!!!!"
        unit.find_new_target(map_state)
        target_xy_hash = MapMachine.convert_string_to_coordinate_xy(unit.target_coordinate_string)
        target_X = target_xy_hash[:x]
        target_Y = target_xy_hash[:y]
      end      

      # Checks to see if unit is already at target
      if target_X && target_Y && !(target_X == unit.coordinate_X && target_Y == unit.coordinate_Y)

        # Set current units current target path
        unit.current_path = PathFinderMachine.search(unit.string_coordinates, unit.target_coordinate_string, map_state)
        unit.path_step_count = 0
      else
        # Unit is already at target coordinate, no path needed
        unit.current_path = []
        unit.path_step_count = 0
      end
    else
      #If no valid unit output for returned movement target, reset path and unit target
      unit.current_path = []
      unit.target_coordinate_string = nil
      unit.path_step_count = 0
    end
  end

end