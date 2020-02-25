module DatabaseInputMachine
  def self.save_after_state_results(spawner_array, turn)
    game = turn.game
    user = turn.user
    spawner_array.each do |spawner_data|
      found_spawner = Spawner.find_by_id(spawner_data["id"])
      if found_spawner
        # Add spawner errors to spawner
        spawner_data["spawner_errors"].each do |spawner_error|
          found_spawner.error_history_array << {turn_count: game.turn_count, error: spawner_error}
          found_spawner.save
          found_spawner.check_for_warning_errors_for_turn()
          found_spawner.check_for_fatal_errors_for_turn()
        end
      end

      # Process returned unit data from spawner
      spawner_data["processed_units"].each do |processed_unit|
        DatabaseInputMachine.update_or_create_unit(processed_unit, turn)
      end
    end

  end

  def self.update_or_create_unit(processed_unit, turn)
      game = turn.game
      unit_to_be_processed = Unit.find_by(uuid: processed_unit["uuid"])
      #If no unit has been found and the unit is specified as new, create new one
      begin
        if !unit_to_be_processed && processed_unit["new"]
          unit_to_be_processed = Unit.new
          unit_to_be_processed.uuid = processed_unit["uuid"]
          unit_to_be_processed.new = true
          unit_to_be_processed.spawner = Spawner.find_by_id(processed_unit["spawner_id"])
          unit_to_be_processed.colour = processed_unit["colour"]
        end

        # Performs common attribute pairing between new/old units
        if unit_to_be_processed
          unit_to_be_processed.unit_output_history_array << {turn_count: game.turn_count, output: processed_unit["latest_unit_output"]}
          # unit_to_be_processed.marshal_object = processed_unit["marshal_object"].force_encoding("ISO-8859-1").encode("UTF-8")
          unit_to_be_processed.marshal_object = processed_unit["marshal_object"]
          unit_to_be_processed.error_history_array << {turn_count: game.turn_count, error_array: processed_unit["errors"]}
          unit_to_be_processed.check_for_warning_errors_for_turn()
          unit_to_be_processed.check_for_fatal_errors_for_turn()
          unit_to_be_processed.save
        else
          raise StandardError("Issue creating/saving unit to Active Record")
        end
      rescue StandardError => error
        puts error
      end

  end
end