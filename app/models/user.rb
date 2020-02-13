class User < ApplicationRecord
  has_many :created_games, :class_name => "Game", :foreign_key => "user_1_id"
  has_many :joined_games, :class_name => "Game", :foreign_key => "user_2_id"
  has_many :spawners

  def skill_rating
    skill_calc = self.wins / self.losses
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
    elsif skill_calc <= 3
      return "Legend"
    elsif skill_calc <= 4
      return "DeepMind"                
    end
  end

  def total_games
    self.wins + self.losses
  end
end
