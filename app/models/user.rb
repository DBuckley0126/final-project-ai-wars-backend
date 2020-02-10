class User < ApplicationRecord
  has_many :created_games, :class_name => "Game", :foreign_key => "user_1_id"
  has_many :joined_games, :class_name => "Game", :foreign_key => "user_2_id"
  has_many :spawners
end
