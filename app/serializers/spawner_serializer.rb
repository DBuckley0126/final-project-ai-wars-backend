class SpawnerSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :game
  belongs_to :user
  has_many :units
  
  attributes :game, :user, :code_string, :active, :colour, :skill_points, :passed_initial_test, :error, :cancelled, :error_history_array, :spawner_name, :units

end
