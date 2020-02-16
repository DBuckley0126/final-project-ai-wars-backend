require_relative '../../app/channels/broadcast_actions/game_instances_overseer_actions.rb'

class Game < ApplicationRecord
  belongs_to :host_user, :polymorphic => true
  belongs_to :join_user, :polymorphic => true, optional: true
  has_many :spawners
  has_many :units, through: :spawners

  before_create :set_colours

  def self.uninitialized_games
    Game.order(:created_at)
    return Game.where(status: "LOBBY", game_initiated: false)
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
      GameInstancesOverseerActions.update_game_instances()
      return self
    else 
      return false
    end
  end

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  private

  def set_colours
    colour_array = ["#34656", "#12356", "#54636"]
    self.host_user_colour = colour_array.sample
    self.join_user_colour = colour_array.sample
  end

  
end
