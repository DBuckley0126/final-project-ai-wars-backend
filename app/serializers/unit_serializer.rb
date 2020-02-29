class UnitSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :spawner
  has_one :game, through: :spawner
  
  attributes :uuid, 
  :attribute_health, 
  :coordinate_Y, 
  :coordinate_X, 
  :base_health, 
  :base_movement, 
  :base_range, 
  :base_melee, 
  :base_vision, 
  :data_set, 
  :error_history_array, 
  :movement_history, 
  :colour, 
  :unit_output_history_array, 
  :active, 
  :marshal_object, 
  :new, 
  :base_spawn_position, 
  :error, 
  :cancelled, 
  :current_path, 
  :target_coordinate_string,
  :path_step_count,
  :obstacle
end
