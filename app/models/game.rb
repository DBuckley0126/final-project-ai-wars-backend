require_relative '../../app/channels/broadcast_actions/cable_helper_actions.rb'
require_relative '../../app/machines/map_machine.rb'


class Game < ApplicationRecord
  belongs_to :host_user, :polymorphic => true
  belongs_to :join_user, :polymorphic => true, optional: true
  has_many :spawners
  has_many :units, through: :spawners
  has_many :turns

  before_create :set_colours

  def self.uninitialized_games
    Game.order(:created_at)
    return Game.where(status: "LOBBY", game_initiated: false)
  end

  def self.get_for_turn(turn)
    turn.game
  end

  def increase_turn_count
    self.turn_count = self.turn_count + 1
    self.save
  end

  def host_user?(user)
    self.host_user === user ? true : false
  end

  def join_user?(user)
    self.join_user === user ? true : false
  end

  def capacity
    if !!self.host_user && !!self.join_user
      return "FULL"
    elsif !!self.host_user || !!self.join_user
      return "WAITING"
    elsif !self.host_user && !self.join_user
      return "EMPTY"
    else
      return "UNKNOWN"
    end
  end

  def add_user(user)

    if self.host_user === user || self.join_user || self.join_user === user
      return false
    end

    self.join_user = user
    successfully_saved_game = self.save

    if successfully_saved_game
      CableHelperActions.update_game_instances()
      return self
    else 
      return false
    end
  end

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def map_state_to_array()
    output_array = []
    self.map_state.each do |key, value|
      output_array.push({xy: key, c: value["contents"], e: value["effect"]})
    end
    output_array
  end

  def create_obstacle_spawner
    # computer_ai_user = User.find_by(sub: "backend|5e45d67f1ba0ebb439e98")
    # binding.pry
    # Spawner.create(game: self, spawner_name: "OBSTACLE" , passed_initial_test: true, obstacle_spawner: true, user: computer_ai_user, colour: "#7aa9de", skill_points: {melee: 0, range: 0, vision: 0, health: 10, movement: 0})
    
  end

  def create_random_obstacles(obstacle_spawner)
    # coordinate_string = "2525"
    # map_state = obstacle_spawner.game.map_state

    # xy_hash = MapMachine.convert_string_to_coordinate_xy(coordinate_string)
    # obstacle_unit = Unit.create(spawner: obstacle_spawner, attribute_health: 10, coordinate_Y: xy_hash[:Y], coordinate_X: xy_hash[:X], base_health: 10, base_movement: 0, base_range: 0, base_melee: 0, base_vision: 0, base_spawn_position: coordinate_string, uuid: rand(1000000000..9999999999), colour: "#7aa9de", new: false, obstacle: true)
    # map_state[coordinate_string]["contents"] = obstacle_unit.uuid
  end

  def init_game
    # self.save
    self.map_state = MapMachine.generate_new_map(self)
    self.game_initiated = true
    self.status = "IN_GAME"
    self.save
  end

  private

  def set_colours
    colour_array = ["#3432a8", "#a83283", "#3ca832", "#a83c32"]
    self.host_user_colour = colour_array.sample
    
    potential_join_user_colour = colour_array.sample

    while potential_join_user_colour == self.host_user_colour
      potential_join_user_colour = colour_array.sample
    end

    self.join_user_colour = potential_join_user_colour
  end

end
