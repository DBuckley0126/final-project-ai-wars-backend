class Spawner < ApplicationRecord
  belongs_to :game
  belongs_to :user
  has_many :units
end
