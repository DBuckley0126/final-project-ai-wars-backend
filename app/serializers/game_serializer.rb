include ActiveRecordFilters
class GameSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :host_user, :polymorphic => true
  belongs_to :join_user, :polymorphic => true
  has_many :spawners
  has_many :units, through: :spawners
  has_many :turns

  attributes :capacity, :uuid, :host_user_ready, :join_user_ready, :game_initiated, :host_user_colour, :join_user_colour, :turn_count, :winner_user_sub
  
  attribute :map_state, &:map_state_to_array

  attribute :join_user do |object|
    object.filtered_api_call(:join_user, [:id, :full_name, :given_name, :family_name, :locale, :picture, :wins, :losses, :skill_rating, :total_games, :sub])
  end
  
  attribute :host_user do |object|
    object.filtered_api_call(:host_user, [:id, :full_name, :given_name, :family_name, :locale, :picture, :wins, :losses, :skill_rating, :total_games, :sub])
  end
end
