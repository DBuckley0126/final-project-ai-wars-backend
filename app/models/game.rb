class Game < ApplicationRecord
  belongs_to :host_user, :polymorphic => true
  belongs_to :join_user, :polymorphic => true
  has_many :spawners
  has_many :units, through: :spawners

  before_create :set_uuid
  before_create :set_colours

  def self.uninitialized_games
    Game.order(created_at: :desc)
    found_games = Game.all.map do |game|
      if  game.capacity === "WAITING" || "FULL"
        if game.game_initiated === false
          return game
        end
      end 
    end
    return found_games
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

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def set_colours
    colour_array = ["#34656", "#12356", "#54636"]
    self.host_user_colour = colour_array.sample
    self.join_user_colour = colour_array.sample
  end

  
end
