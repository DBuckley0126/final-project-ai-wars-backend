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

  def self.find_nearest_avilable_coordinate(map_state, current_coordinate_string, target_coordinate_string)
    current_xy_hash = MapMachine.convert_string_to_coordinate_xy(current_coordinate_string)
    target_xy_hash = MapMachine.convert_string_to_coordinate_xy(target_coordinate_string)

    # Decide which side the unit is coming from

    if current_xy_hash[:x] <= target_xy_hash[:x]
      side = "host_user"
    else
      side = "join_user"
    end

    initial_target_x = target_xy_hash[:x]
    initial_target_y = target_xy_hash[:y]

    # Initial position
    center = MapMachine.convert_xy_to_coordinate_string(initial_target_x, initial_target_y)

    # North position
    n_x = initial_target_x
    n_y = initial_target_y + 1
    n = MapMachine.convert_xy_to_coordinate_string(n_x, n_y)

    # North East position
    ne_x = initial_target_x + 1
    ne_y = initial_target_y + 1
    ne = MapMachine.convert_xy_to_coordinate_string(ne_x, ne_y)

    # East position
    e_x = initial_target_x + 1
    e_y = initial_target_y
    e = MapMachine.convert_xy_to_coordinate_string(e_x, e_y)

    # South East position
    se_x = initial_target_x + 1
    se_y = initial_target_y - 1
    se = MapMachine.convert_xy_to_coordinate_string(se_x, se_y)

    # South position
    s_x = initial_target_x 
    s_y = initial_target_y - 1
    s = MapMachine.convert_xy_to_coordinate_string(s_x, s_y)

    # South West position
    sw_x = initial_target_x - 1
    sw_y = initial_target_y - 1
    sw = MapMachine.convert_xy_to_coordinate_string(sw_x, sw_y)

    # West position
    w_x = initial_target_x - 1
    w_y = initial_target_y
    w = MapMachine.convert_xy_to_coordinate_string(w_x, w_y)

    # North West position
    nw_x = initial_target_x - 1
    nw_y = initial_target_y + 1
    nw = MapMachine.convert_xy_to_coordinate_string(nw_x, nw_y)    

    # Adjust check order based on which side the unit was spawned
    if side === "host_user"
      position_check_priority = [center, w, sw, nw, s, n, se, ne, e]
    else 
      position_check_priority = [center, e, se, ne, s, n, sw, nw, w]
    end

    # Check if unit is already next to target
    position_check_priority.each do |potential_target_coordinate_string|
      if potential_target_coordinate_string === current_coordinate_string
        return potential_target_coordinate_string
      end
    end
    
    # Check nearest coordinates for available space
    position_check_priority.each do |potential_target_coordinate_string|
      if map_state[potential_target_coordinate_string] && !map_state[potential_target_coordinate_string]["contents"]
        return potential_target_coordinate_string
      end
    end

    #If no spaces available next to target, begin second stage area cycling 
    distance = 2
    range = 4

    searching = true

    while searching
      # Get lowest coordinate of search area
      lowest_x = initial_target_x - distance
      lowest_y = initial_target_y - distance

      potential_target_coordinate_strings = []

      generating = true
      y_count = 0
      x_count = 0

      while generating
        # Generate string from current position
        x = lowest_x + x_count
        y = lowest_y + y_count

        potential_target_coordinate_strings << MapMachine.convert_xy_to_coordinate_string(x, y)

        # Cycle through layers of area, creating strings, stopping at current range
        if y_count == range
          generating = false
          y_count = 0
          x_count = 0
        elsif x_count == range
          y_count += 1
          x_count = 0
        else
          x_count += 1
        end
      end

      # Check if unit is already next to target
      potential_target_coordinate_strings.each do |coordinate_string|
        if coordinate_string === current_coordinate_string
          return coordinate_string
        end
      end

      # Check potential strings created from area for being valid and not containing any contents
      valid_coordinate_strings = []
      potential_target_coordinate_strings.each do |coordinate_string|
        # If valid position and empty, return and exit
        if map_state[coordinate_string] && !map_state[coordinate_string]["contents"]
          valid_coordinate_strings << coordinate_string
        end
      end

      # Pick random coordinate string from array if one available
      if valid_coordinate_strings.length >= 1
        searching = false
        return valid_coordinate_strings.sample
      end

      # Limit on positions generated
      puts "LIMIT HIT!!!!!!!!!!"
      if potential_target_coordinate_strings.length > 2000
        return false
      end

      # Increase area
      potential_target_coordinate_strings = []
      range += 2
      distance += 1

    end

    return false
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



