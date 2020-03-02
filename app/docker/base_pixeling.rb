class BasePixeling
  
  attr_reader :base_vision, :unit_vision, :game_data, :skill_points, :unit_health 

  def set_payload_data(data)
    @base_vision = data["base_vision"]
    @unit_vision = data["unit_vision"]
    @game_data = data["game_data"]
    @skill_points = data["skill_points"]
    @unit_health = data["unit_health"]

  end

end
