require_relative '../../app/channels/broadcast_actions/cable_helper_actions.rb'
require_relative '../../app/machines/map_machine.rb'


class Game < ApplicationRecord
  belongs_to :host_user, :polymorphic => true
  belongs_to :join_user, :polymorphic => true, optional: true
  has_many :spawners
  has_many :units, through: :spawners
  has_many :turns

  before_create :set_colours, :set_initial_map_state

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
      output_array.push({xy: key, c: value["contents"]})
    end
    output_array
  end

  private

  def set_colours
    colour_array = ["#3432a8", "#a83283", "#3ca832", "#a83c32"]
    self.host_user_colour = colour_array.sample
    self.join_user_colour = colour_array.sample
  end

  def set_initial_map_state
    self.map_state = MapMachine.generate_new_map()
  end

  
end
