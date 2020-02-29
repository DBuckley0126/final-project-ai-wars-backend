class Unit < ApplicationRecord
  belongs_to :spawner
  has_one :game, through: :spawner

  def self.find_all_friendly_units(turn)
    game = turn.game
    user = turn.user
    all_active_units = Unit.where( active: true).order(:id)

    friendly_output_array = []

    all_active_units.each do |unit|
      if unit.spawner.game === game && unit.spawner.user === user 
        friendly_output_array << unit
      end
    end
    friendly_output_array
  end

  def self.create_obstacle_unit(spawner, coordinate_string)

  end

  def self.get_for_turn(turn)
    turn.game.units
  end

  def self.find_by_uuid(uuid)
    Unit.find_by(uuid: uuid)
  end

  def self.save_collection(units)
    units.each { |unit| unit.save! }
  end

  def user_type
    game = self.spawner.game

    if self.user === game.host_user
      return "host_user"
    elsif self.user === game.join_user
      return "join_user"
    else
      return false
    end
  end

  def damage(amount)
    self.attribute_health -= amount
    if self.attribute_health <= 0
      self.deactivate
    end
    self.save
  end

  def deactivate
    map_state = self.spawner.game.map_state

    self.active = false
    map_state[self.string_coordinates]["contents"] = 0

    self.save
  end

  def user
    self.spawner.user
  end

  def find_new_target(map_state)
    closest_coordinate_string = MapMachine.find_nearest_avilable_coordinate(map_state, self.string_coordinates, self.target_coordinate_string)
    # If unit is already next to desired target, set target to current position
    if closest_coordinate_string == self.string_coordinates
      self.target_coordinate_string = closest_coordinate_string
    # If target coordinate taken and has available space next to it  
    elsif closest_coordinate_string
      self.target_coordinate_string = closest_coordinate_string
      self.add_error_for_turn({completed_cycle: false, error_type: "WARNING", error_message: "Target coordinate was unavailable, moved target to nearest available coordinate."})
    # If target coordinate taken and no space available next to it
    else 
      self.add_error_for_turn({completed_cycle: false, error_type: "WARNING", error_message: "Target coordinate was unavailable and no available coordinates nearby"})
    end
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

  def add_error_for_turn(error)
    found_errors_for_turn = self.error_history_array.find { |error_turn| error_turn[:turn_count] === self.game.turn_count }
    if found_errors_for_turn
      found_errors_for_turn[:error_array] << error
    else
      self.error_history_array << {turn_count: game.turn_count, error_array: [error]}
    end
    self.save
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
    errors = self.error_history_array.any? { |error_turn| error_turn[:turn_count] === self.game.turn_count && error_turn[:error_array].any? { |error| error["error_type"] === "CRITICAL HASH REQUIREMENT" || error["error_type"] === "CRITICAL"} }
    if errors
      self.error = true
      self.cancelled = true
      self.active = false
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
