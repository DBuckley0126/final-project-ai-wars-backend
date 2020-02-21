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

end
