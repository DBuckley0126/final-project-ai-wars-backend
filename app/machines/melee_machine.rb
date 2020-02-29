module MeleeMachine
  def self.process_unit_melee_attack(turn)
    all_friendly_active_units = Unit.find_all_friendly_units(turn)


    2.times do |step_number|
      MeleeMachine.process_step(all_friendly_active_units, turn, step_number)
      turn.map_states_for_turn[turn.step_count] = turn.game.map_state_to_array()
      turn.step_count += 1
    end

    # Save all processed units
    Unit.save_collection(all_friendly_active_units)
    turn.save
    turn.game.save
  end

  def self.process_step(freindly_units, turn, step_number)
    # complete path finding of unit if under melee limit

    case step_number
    when 0
      freindly_units.each do |unit|
        MeleeMachine.add_melee_markers(unit, turn)
      end
    when 1
      freindly_units.each do |unit|
          MeleeMachine.process_unit_melee(unit, turn)
      end
    when 2
      MapMachine.reset_effects(turn.game.map_state)
    end
  end

  def self.add_melee_markers(unit, turn)
    map_state = turn.game.map_state
    found_unit_output = unit.unit_output_history_array.find { |unit_output| unit_output["turn_count"] === turn.turn_count }

    attack_direction = nit.user_type === "host_user" ? "EAST" : "WEST"
    attack_boolean = true

    if found_unit_output && 
      found_unit_output["output"]["melee"] &&
      [true, false].include?(found_unit_output["output"]["melee"]["attack"])

      attack_boolean = found_unit_output["output"]["melee"]["attack"]
    end

    if found_unit_output && 
      found_unit_output["output"]["melee"] &&
      found_unit_output["output"]["melee"]["direction"]

      attack_direction = found_unit_output["output"]["melee"]["direction"]
    end

    if attack_boolean
      attack_target_coordinate_string = MapMachine.get_relative_string_coordinate(unit.string_coordinates, attack_direction, 1)
      if map_state[attack_target_coordinate_string]
        map_state[attack_target_coordinate_string]["effect"] = 1
      end
    end
  end

  def self.process_unit_melee_attack(unit, turn)
    map_state = turn.game.map_state
    found_unit_output = unit.unit_output_history_array.find { |unit_output| unit_output["turn_count"] === turn.turn_count }

    attack_direction = nit.user_type === "host_user" ? "EAST" : "WEST"
    attack_boolean = true

    if found_unit_output && 
      found_unit_output["output"]["melee"] &&
      [true, false].include?(found_unit_output["output"]["melee"]["attack"])

      attack_boolean = found_unit_output["output"]["melee"]["attack"]
    end

    if found_unit_output &&
      found_unit_output["output"]["melee"] &&
      found_unit_output["output"]["melee"]["direction"]

      attack_direction = found_unit_output["output"]["melee"]["direction"]
    end

    if attack_boolean
      attack_target_coordinate_string = MapMachine.get_relative_string_coordinate(unit.string_coordinates, attack_direction, 1)
      if map_state[attack_target_coordinate_string] && map_state[attack_target_coordinate_string]["contents"]
        found_unit = Unit.find_by_uuid(map_state[attack_target_coordinate_string]["contents"])

        if found_unit
          found_unit.damage(unit.base_melee)
        end
      end
    end

  end

end