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

  def host_user_base_health
    map_state = self.map_state

    level_1_count = 0
    level_2_count = 0

    x_level_1 = 1
    x_level_2 = 2

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_1, y)
      contents = map_state[string_coordinate]["contents"]
      if contents && contents.digits.count == 9
        level_1_count +=1
      end
      y += 1
    end

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_2, y)
      contents = map_state[string_coordinate]["contents"]
      if contents && contents.digits.count == 9
        level_2_count +=1
      end
      y += 1
    end

    if level_1_count != 50
      return 0
    elsif level_2_count != 50
      return 1
    else
      return 2
    end
  end

  def join_user_base_health
    map_state = self.map_state

    level_1_count = 0
    level_2_count = 0

    x_level_1 = 50
    x_level_2 = 49

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_1, y)
      contents = map_state[string_coordinate]["contents"]
      if contents && contents.digits.count == 9
        level_1_count +=1
      end
      y += 1
    end

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_2, y)
      contents = map_state[string_coordinate]["contents"]
      if contents && contents.digits.count == 9
        level_2_count +=1
      end
      y += 1
    end

    if level_1_count != 50
      return 0
    elsif level_2_count != 50
      return 1
    else
      return 2
    end
  end

  def host_user_base_vision
    map_state = self.map_state

    output_array = []

    x_level_1 = 3
    x_level_2 = 4

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_1, y)
      contents = map_state[string_coordinate]["contents"]
      if contents
        found_unit = Unit.find_by_uuid(contents)
        if found_unit
          output_array << found_unit
        end
      end
      y += 1
    end

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_2, y)
      contents = map_state[string_coordinate]["contents"]
      if contents
        found_unit = Unit.find_by_uuid(contents)
        if found_unit
          output_array << found_unit
        end
      end
      y += 1
    end

    output_array
  end

  def join_user_base_vision
    map_state = self.map_state

    output_array = []

    x_level_1 = 48
    x_level_2 = 47

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_1, y)
      contents = map_state[string_coordinate]["contents"]
      if contents
        found_unit = Unit.find_by_uuid(contents)
        if found_unit
          output_array << found_unit
        end
      end
      y += 1
    end

    y = 1

    50.times do 
      string_coordinate = MapMachine.convert_xy_to_coordinate_string(x_level_2, y)
      contents = map_state[string_coordinate]["contents"]
      if contents
        found_unit = Unit.find_by_uuid(contents)
        if found_unit
          output_array << found_unit
        end
      end
      y += 1
    end

    output_array
  end

  def map_state_to_array()
    output_array = []
    self.map_state.each do |key, value|
      output_array.push({xy: key, c: value["contents"], e: value["effect"]})
    end
    output_array
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
