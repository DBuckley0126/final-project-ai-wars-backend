class Game < ApplicationRecord
  belongs_to :user_1, :class_name => "User"
  belongs_to :user_2, :class_name => "User"
  has_many :spawners
  has_many :units, through: :spawners

  before_create :set_uuid
  before_create :set_colours

  def self.uninitialized_games
    User.order(created_at: :desc)
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
    if self.user_1 && self.user_2
      return "FULL"
    elsif self.user_1 || self.user_2
      return "WAITING"
    elsif !self.user_1 && self.user_2
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
    self.user_1_colour = colour_array.sample
    self.user_2_colour = colour_array.sample
  end

  
end
