class Game < ApplicationRecord
  belongs_to :user_1, :class_name => "User"
  belongs_to :user_2, :class_name => "User"
  has_many :spawners
  has_many :units, through: :spawners
end
