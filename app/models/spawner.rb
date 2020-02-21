require_relative '../machines/test_machine'
class Spawner < ApplicationRecord
  belongs_to :game
  belongs_to :user
  has_many :units

  def self.attempt_create(user, game, turn_payload)
    test_object_1 = TestMachine.turn_payload_content_check(turn_payload)

    test_object_2 = TestMachine.initial_class_security_test(turn_payload["new_spawner_class"])

    if test_object_1[:test_results] === "PASS" && test_object_2[:test_results] === "PASS"
      Spawner.create(
        user: user, 
        game: game,
        code_string: turn_payload["new_spawner_class"],
        skill_points: turn_payload["new_spawner_skills"],
        active: true, 
        error: false, 
        cancelled: false, 
        passed_initial_test: true,
        spawner_name: turn_payload["new_spawner_name"],
        colour: turn_payload["new_spawner_colour"]
      )
    elsif test_object_1[:test_results] === "FAIL"
      Spawner.create(
        user: user,
        game: game,
        active: false, 
        error: true, 
        cancelled: true, 
        passed_initial_test: false,
        spawner_name: turn_payload["new_spawner_name"],
        error_history_array: [{turn_count: game.turn_count, error: {test_results: test_object_1[:test_results], error_type: test_object_1[:error_type], message: test_object_1[:message]}}]
      )
    elsif test_object_2[:test_results] === "FAIL" 
      Spawner.create(
        user: user,
        game: game,
        active: false, 
        error: true, 
        cancelled: true, 
        passed_initial_test: false,
        spawner_name: turn_payload["new_spawner_name"],
        error_history_array: [{turn_count: game.turn_count, error: {test_results: test_object_2[:test_results], error_type: test_object_2[:error_type], message: test_object_2[:message]}}]
      )
    end

    def self.get_for_turn(turn)
      Spawner.where(game: turn.game)
    end

    def check_for_fatal_errors_for_turn()
      errors = self.error_history_array.any? { |error| error[:turn_count] === self.game.turn_count && error[:error]["test_result"] === "FAIL" }
      if errors
        self.error = true
        self.cancelled = true
      end
      self.save
    end

    def check_for_warning_errors_for_turn()
      errors = self.error_history_array.any? { |error| error[:turn_count] === self.game.turn_count && error[:error]["test_result"] === "WARNING" }
      if errors
        self.error = true
      else
        self.error = false
      end
      self.save
    end

  end


end
