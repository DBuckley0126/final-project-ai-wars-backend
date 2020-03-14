class User < ApplicationRecord
  has_many :games, :as => :host_user
  has_many :games, :as => :join_user
  has_many :spawners
  has_many :turns, through: :games

  def hosted_games
    Game.where(host_user_id: self.id)
  end

  def joined_games
    Game.where(join_user_id: self.id)
  end

  def add_win
    self.wins += 1
    self.save
  end

  def add_loss
    self.losses += 1
    self.save
  end

  def skill_rating
    losses = self.losses === 0 ? 1 : self.losses
    if self.wins === 0 && self.losses === 0
      skill_calc = 0
    else
      skill_calc = self.wins / losses
    end
  
    if self.total_games < 5
      return "New"
    elsif skill_calc <= 0.5
      return "Rookie"
    elsif skill_calc <= 1
      return "Semi-Pro"
    elsif skill_calc <= 1.4
      return "Pro"
    elsif skill_calc <= 1.8
      return "Veteran"
    elsif skill_calc <= 2.2
      return "Expert"  
    elsif skill_calc <= 2.5
      return "Master"
    elsif skill_calc <= 3.5
      return "Legend"
    elsif skill_calc > 3.5
      return "DeepMind"                
    end
  end

  def total_games
    self.wins + self.losses
  end

  def full_name
    "#{self.given_name} #{self.family_name}"
  end
end
