class Unit < ApplicationRecord
  belongs_to :spawner
  has_one :game, through: :spawner
end
