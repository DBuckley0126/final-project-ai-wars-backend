class GameSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :user_1, :class_name => "User"
  belongs_to :user_2, :class_name => "User"
  has_many :spawners
  has_many :units, through: :spawners

  attributes :capacity, :uuid, :user_1, :user_2, :user_1_ready, :user_2_ready, :game_initiated, :user_1_colour, :user_2_colour

  # attribute :leaderboard_entries do |object|
  #   object.filtered_api_call(:leaderboard_entries, [:id, :score])
  # end
end
