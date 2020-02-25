class Unit < ApplicationRecord
  belongs_to :spawner
  has_one :game, through: :spawner

  def self.find_all_friendly_units(turn)
    game = turn.game
    user = turn.user
    all_active_units = Unit.where( active: true)

    friendly_output_array = []

    all_active_units.each do |unit|
      if unit.spawner.game === game && unit.spawner.user === user 
        friendly_output_array << unit
      end
    end
    friendly_output_array
  end

  def self.get_for_turn(turn)
    turn.game.units
  end

  def string_coordinates
    output_X_string = nil
    output_Y_string = nil

    if self.coordinate_X.to_s.length === 1
      output_X_string = "0" + self.coordinate_X.to_s
    else
      output_X_string = self.coordinate_X.to_s
    end

    if self.coordinate_Y.to_s.length === 1
      output_Y_string = "0" + self.coordinate_Y.to_s
    else
      output_Y_string = self.coordinate_Y.to_s
    end

    output_X_string + output_Y_string
  end

  def self.find_all_enemy_units(turn)
    game = turn.game
    user = turn.user
    all_active_units = Unit.where(active: true)

    enemy_output_array = []

    all_active_units.each do |unit|
      if unit.spawner.game === game && !unit.spawner.user === user
        enemy_output_array << unit
      end
    end
    enemy_output_array
  end

  def self.find_all_active_units(turn)
    game = turn.game
    Unit.where(game: game, active: true)
  end

  def check_for_fatal_errors_for_turn
    errors = self.error_history_array.any? { |error_turn| error_turn[:turn_count] === self.game.turn_count && error_turn[:error_array].any? { |error| error["error_type"] === "CRITICAL HASH REQUIREMENT"} }
    if errors
      self.error = true
      self.cancelled = true
    end
    self.save
  end

  def check_for_warning_errors_for_turn
    errors = self.error_history_array.any? { |error_turn| error_turn[:turn_count] === self.game.turn_count && error_turn[:error_array].any? { |error| error["error_type"] === "WARNING"} }
    if errors
      self.error = true
    else
      self.error = false
    end
    self.save
  end

end
