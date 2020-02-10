class Unit < ApplicationRecord
  belongs_to :spawner
  belongs_to :game, through: :spawner
end
