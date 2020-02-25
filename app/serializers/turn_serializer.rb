class TurnSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :user
  belongs_to :game
  
  attributes :errors_for_turn_array, :user_turn_payload, :uuid, :units_output_for_turn_array, :current_game_state, :turn_count, :map_states_for_turn

  attribute :user do |object|
    object.filtered_api_call(:user, [:id, :full_name, :given_name, :family_name])
  end

  attribute :game do |object|
    object.filtered_api_call(:game, [:uuid])
  end


end
