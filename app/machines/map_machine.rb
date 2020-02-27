require_relative "../lib/classes/node.rb"

module MapMachine
  def self.reset_nodes(map_state)
    map_state.each do |coordinate, value|
      value[:node].reset()
    end
  end
  
  def self.update_position(map_state, string_coordinates, contents)
    map_state[string_coordinates]["contents"] = contents
  end

  def self.find_unit_in_map(map_state, unit)
    found_unit_coordinate = false
    map_state.each do |coordinate_key, value|
      if value["contents"] === unit.uuid
        found_unit_coordinate = coordinate_key
      end
    end
    found_unit_coordinate
  end

  def self.closest_available_y(map_state, string_coordinates)
    xy_hash = MapMachine.convert_string_to_coordinate_xy(string_coordinates)

    initial_x = xy_hash[:x]
    initial_y = xy_hash[:y]

    distance = 1

    searching = true

    while searching

      potential_plus_y = initial_y + distance
      potential_minus_y = initial_y - distance

      potential_plus_coordinate_string = MapMachine.convert_xy_to_coordinate_string(initial_x, potential_plus_y)
      potential_minus_coordinate_string = MapMachine.convert_xy_to_coordinate_string(initial_x, potential_minus_y)

      if map_state[potential_plus_coordinate_string] && !map_state[potential_plus_coordinate_string]["contents"]
        searching = false
        return potential_plus_coordinate_string
      end

      if map_state[potential_minus_coordinate_string] && !map_state[potential_minus_coordinate_string]["contents"]
        searching = false
        return potential_minus_coordinate_string
      end

      distance += 1
    end

    return false
  end

  def self.any_available_y(map_state, coordinate_X)
    random_Y = rand(1..50)

    coordinate_string = MapMachine.convert_xy_to_coordinate_string(coordinate_X, random_Y)

    if !map_state[coordinate_string]["contents"]
      return coordinate_string
    end

    MapMachine.closest_available_y(map_state, coordinate_string)
  end
  
  def self.generate_new_map
    initial_map_state = {}
    
    current_Y = 101
    current_X = 101
    
    2500.times do
      if current_X === 151
        current_Y += 1
        current_X = 101
      end
    
      key = current_X.to_s.slice(1,3) + current_Y.to_s.slice(1,3)
    
      initial_map_state[key] = {contents: nil}
    
      current_X += 1
    end
    
    initial_map_state
  end

  def self.convert_xy_to_coordinate_string(x, y)
    string_x = x.to_s
    string_y = y.to_s
  
    if string_x.length <= 1
      string_x = "0" + string_x
    end
  
    if string_y.length <= 1
      string_y = "0" + string_y
    end

    "#{string_x}#{string_y}"
  end

  def self.convert_string_to_coordinate_xy(coordinate_key)
    x = coordinate_key.slice(0,2).to_i
    y = coordinate_key.slice(2, 2).to_i

    {x: x, y: y}
  end
end



