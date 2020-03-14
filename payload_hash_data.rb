payload_hash = {
  base_vision: "Array of units within distance of base",
  pixeling_vision: {
    freindly_pixelings: "Array of friendly units within unit vision",
    enemy_pixelings: "Array of enemy units within unit vision",
    obstacles: "Array of obstacles within unit vision",
  },
  game_data: {
    turn_count: "Game turn count, Integer",
    active_friendly_pixelings: "Array of all active friendly units",
    active_enemy_pixelings_count: "Count for how many enemy units currently active on map, Integer",
    friendly_base_health: "The health of friendly player base, Integer",
    enemy_base_health: "The health of enemy player base, Integer"
  },
  skill_points: {
    health: Integer,
    melee: Integer,
    movement: Integer,
    range: Integer,
    vision: Integer,
  },
  pixeling_data: {
    health: "Pixeling current health, Integer",
    coordinate_X: "Pixeling current X coordinate, Integer",
    coordinate_Y: "Pixeling current Y coordinate, Integer",
    current_coordinate_string: "Pixeling current coordinates in string format(always 4 digits long), String",
    target_coordinate_string: "Pixeling target coordinates in string format(always 4 digits long), String",
    previous_coordinate_path: "Pixeling current path in coordinate strings (always 4 digits long), Array"
  }
}

# Enemy unit data structure
{
  distance: distance_between,
  health: obstacle.attribute_health,
  coordinate_Y: obstacle.coordinate_Y,
  coordinate_X: obstacle.coordinate_X,
  string_coordinate: obstacle.string_coordinates
}

# Freindly unit data structure
{
  distance: distance_between,
  spawner_name: friendly_unit.spawner.spawner_name,
  health: friendly_unit.attribute_health,
  coordinate_Y: friendly_unit.coordinate_Y,
  coordinate_X: friendly_unit.coordinate_X,
  base_health: friendly_unit.base_health,
  base_melee: friendly_unit.base_melee,
  base_movement: friendly_unit.base_movement,
  base_range: friendly_unit.base_range,
  base_vision: friendly_unit.base_vision,
  base_spawn_position: friendly_unit.base_spawn_position,
  string_coordinate: friendly_unit.string_coordinates
}


class Pixeling < BasePixeling
  def movement
    closest_enemy_pixeling = @pixeling_vision["enemy_pixelings"][0]
    
    if closest_enemy_pixeling
      enemy_y = closest_enemy_pixeling["coordinate_Y"]
      enemy_x = closest_enemy_pixeling["coordinate_X"]
      return {target:{X: enemy_x - 1, Y: enemy_y}}
    else
      self.patrol
    end 
    
  end
  
  def spawn_position
    {Y: 15}
  end
  
  def patrol
    if @game_data["turn_count"].odd?()
      return {target:{X: 7, Y:15}}
    else
      return {target:{X: 7, Y:11}}
    end
  end
end