require_relative "../lib/classes/node.rb"
require_relative "../lib/modules/map_presets.rb"

module MapMachine
  
  def self.update_position(map_state, string_coordinates, contents)
    map_state[string_coordinates]["contents"] = contents
  end

  def self.reset_effects(map_state)
    map_state.each do |coordinate_key, value|
      map_state[coordinate_key]["effect"] = 0
    end
  end

  def self.get_relative_string_coordinate(current_coordinate_string, direction, distance)
    current_xy_hash = MapMachine.convert_string_to_coordinate_xy(current_coordinate_string)
    initial_target_x = current_xy_hash[:x]
    initial_target_y = current_xy_hash[:y]

    # North position
    n_x = initial_target_x
    n_y = initial_target_y + distance
    n = MapMachine.convert_xy_to_coordinate_string(n_x, n_y)

    # North East position
    ne_x = initial_target_x + distance
    ne_y = initial_target_y + distance
    ne = MapMachine.convert_xy_to_coordinate_string(ne_x, ne_y)

    # East position
    e_x = initial_target_x + distance
    e_y = initial_target_y
    e = MapMachine.convert_xy_to_coordinate_string(e_x, e_y)

    # South East position
    se_x = initial_target_x + distance
    se_y = initial_target_y - distance
    se = MapMachine.convert_xy_to_coordinate_string(se_x, se_y)

    # South position
    s_x = initial_target_x 
    s_y = initial_target_y - distance
    s = MapMachine.convert_xy_to_coordinate_string(s_x, s_y)

    # South West position
    sw_x = initial_target_x - distance
    sw_y = initial_target_y - distance
    sw = MapMachine.convert_xy_to_coordinate_string(sw_x, sw_y)

    # West position
    w_x = initial_target_x - distance
    w_y = initial_target_y
    w = MapMachine.convert_xy_to_coordinate_string(w_x, w_y)

    # North West position
    nw_x = initial_target_x - distance
    nw_y = initial_target_y + distance
    nw = MapMachine.convert_xy_to_coordinate_string(nw_x, nw_y) 

    case true
    when direction === "NORTH"
      return n
    when direction === "NORTH_EAST"
      return ne
    when direction === "EAST"
      return e 
    when direction === "SOUTH_EAST"
      return se 
    when direction === "SOUTH"
      return s
    when direction === "SOUTH_WEST"
      return sw
    when direction === "WEST"
      return w
    when direction === "NORTH_WEST"
      return nw                          
    end

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
    target_xy_hash = MapMachine.convert_string_to_coordinate_xy(target_coordinate_string)

    initial_target_x = target_xy_hash[:x]
    initial_target_y = target_xy_hash[:y]

    first_level_coordinate_strings = {}
    core_level_coordinate_strings = {}

    # Initial position
    center = MapMachine.convert_xy_to_coordinate_string(initial_target_x, initial_target_y)
    center_distance = MapMachine.distance(current_coordinate_string, center)
    first_level_coordinate_strings[center] = center_distance
    core_level_coordinate_strings[center] = center_distance

    # North position
    n_x = initial_target_x
    n_y = initial_target_y + 1
    n = MapMachine.convert_xy_to_coordinate_string(n_x, n_y)
    n_distance = MapMachine.distance(current_coordinate_string, n)
    first_level_coordinate_strings[n] = n_distance
    core_level_coordinate_strings[n] = n_distance

    # North East position
    ne_x = initial_target_x + 1
    ne_y = initial_target_y + 1
    ne = MapMachine.convert_xy_to_coordinate_string(ne_x, ne_y)
    ne_distance = MapMachine.distance(current_coordinate_string, ne)
    first_level_coordinate_strings[ne] = ne_distance


    # East position
    e_x = initial_target_x + 1
    e_y = initial_target_y
    e = MapMachine.convert_xy_to_coordinate_string(e_x, e_y)
    e_distance = MapMachine.distance(current_coordinate_string, e)
    first_level_coordinate_strings[e] = e_distance
    core_level_coordinate_strings[e] = e_distance


    # South East position
    se_x = initial_target_x + 1
    se_y = initial_target_y - 1
    se = MapMachine.convert_xy_to_coordinate_string(se_x, se_y)
    se_distance = MapMachine.distance(current_coordinate_string, se)
    first_level_coordinate_strings[se] = se_distance

    # South position
    s_x = initial_target_x 
    s_y = initial_target_y - 1
    s = MapMachine.convert_xy_to_coordinate_string(s_x, s_y)
    s_distance = MapMachine.distance(current_coordinate_string, s)
    first_level_coordinate_strings[s] = s_distance
    core_level_coordinate_strings[s] = s_distance

    # South West position
    sw_x = initial_target_x - 1
    sw_y = initial_target_y - 1
    sw = MapMachine.convert_xy_to_coordinate_string(sw_x, sw_y)
    sw_distance = MapMachine.distance(current_coordinate_string, sw)
    first_level_coordinate_strings[sw] = sw_distance


    # West position
    w_x = initial_target_x - 1
    w_y = initial_target_y
    w = MapMachine.convert_xy_to_coordinate_string(w_x, w_y)
    w_distance = MapMachine.distance(current_coordinate_string, w)
    first_level_coordinate_strings[w] = w_distance
    core_level_coordinate_strings[w] = w_distance

    # North West position
    nw_x = initial_target_x - 1
    nw_y = initial_target_y + 1
    nw = MapMachine.convert_xy_to_coordinate_string(nw_x, nw_y) 
    nw_distance = MapMachine.distance(current_coordinate_string, nw)
    first_level_coordinate_strings[nw] = nw_distance

    # Sort distances into ascending order for first level(N, NE, E, SE, S, SW, W, NW)
    first_level_sorted_array = first_level_coordinate_strings.sort_by {|k, v| v}
    first_level_sorted_hash = first_level_sorted_array.to_h
    first_level_position_check_priority = first_level_sorted_hash.keys

    # Sort distances into ascending order for core level(N, E, S, W)
    core_level_sorted_array = core_level_coordinate_strings.sort_by {|k, v| v}
    core_level_sorted_hash = core_level_sorted_array.to_h
    core_level_position_check_priority = core_level_sorted_hash.keys

    # Check if unit is already at core level(N, E, S, W)
    core_level_position_check_priority.each do |potential_target_coordinate_string|
      if potential_target_coordinate_string === current_coordinate_string
        return potential_target_coordinate_string
      end
    end    

    # Check nearest coordinates for available space at core level(N, E, S, W)
    core_level_position_check_priority.each do |potential_target_coordinate_string|
      if map_state[potential_target_coordinate_string] && !map_state[potential_target_coordinate_string]["contents"]
        return potential_target_coordinate_string
      end
    end

    # Check if unit is already at first level(N, NE, E, SE, S, SW, W, NW)
    first_level_position_check_priority.each do |potential_target_coordinate_string|
      if potential_target_coordinate_string === current_coordinate_string
        return potential_target_coordinate_string
      end
    end    
    
    # Check nearest coordinates for available space at first level(N, NE, E, SE, S, SW, W, NW)
    first_level_position_check_priority.each do |potential_target_coordinate_string|
      if map_state[potential_target_coordinate_string] && !map_state[potential_target_coordinate_string]["contents"]
        return potential_target_coordinate_string
      end
    end

    #If no spaces available at first level, begin second stage area cycling 
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

      # Calculate distances for valid empty string coordinates
      coordinate_string_distances_hash = {}
      valid_coordinate_strings.each do |potential_coordinate_string|
        distance = MapMachine.distance(current_coordinate_string, potential_coordinate_string)
        coordinate_string_distances_hash[potential_coordinate_string] = distance
      end

      # Sort distances in ascending order
      outer_level_sorted_array = coordinate_string_distances_hash.sort_by {|k, v| v}
      outer_level_sorted_hash = outer_level_sorted_array.to_h
      outer_level_position_priority = outer_level_sorted_hash.keys

      # Return nearest available coordinate position
      outer_level_position_priority.each do |potential_target_coordinate_string|
        if map_state[potential_target_coordinate_string] && !map_state[potential_target_coordinate_string]["contents"]
          return potential_target_coordinate_string
        end
      end

      # Limit on positions generated
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

  def self.distance(current_coordinate_string, target_coordinate_string)
    current_xy_hash = MapMachine.convert_string_to_coordinate_xy(current_coordinate_string)
    target_xy_hash = MapMachine.convert_string_to_coordinate_xy(target_coordinate_string)

    return (
      (current_xy_hash[:x] - target_xy_hash[:x]) ** 2 +
      (current_xy_hash[:y] - target_xy_hash[:y]) ** 2
    ) ** (0.5)
  end
  
  def self.generate_new_map(game)
    initial_map_state = {}
    
    current_Y = 101
    current_X = 101
    
    2500.times do
      if current_X === 151
        current_Y += 1
        current_X = 101
      end
    
      key = current_X.to_s.slice(1,3) + current_Y.to_s.slice(1,3)
    
      initial_map_state[key] = {contents: nil, effect: 0}
    
      current_X += 1
    end

    # Create obstacle & base spawners
    computer_ai_user = User.find_by(sub: "backend|5e45d67f1ba0ebb439e98")
    obstacle_spawner = Spawner.create(game: game, spawner_name: "OBSTACLE" , passed_initial_test: true, obstacle_spawner: true, user: computer_ai_user, colour: "#7aa9de", skill_points: {melee: 0, range: 0, vision: 0, health: 10, movement: 0})
    base_spawner = Spawner.create(game: game, spawner_name: "BASE" , passed_initial_test: true, base_spawner: true, user: computer_ai_user, colour: "#7aa9de", skill_points: {melee: 0, range: 0, vision: 0, health: 10, movement: 0})
   
    # Create bases
    coordinate_string_base_preset = MapPresets.empty
    coordinate_string_base_preset.each do |coordinate_string|
      xy_hash = MapMachine.convert_string_to_coordinate_xy(coordinate_string)
      base_unit = Unit.create(spawner: base_spawner, attribute_health: 10, coordinate_Y: xy_hash[:y], coordinate_X: xy_hash[:x], base_health: 10, base_movement: 0, base_range: 0, base_melee: 0, base_vision: 0, base_spawn_position: coordinate_string, uuid: rand(1000000000..9999999999), colour: "#7aa9de", new: false, base: true)
      initial_map_state[coordinate_string]["contents"] = base_unit.uuid
    end

    # Create obstacles
    coordinate_string_map_preset = MapPresets.empty
    coordinate_string_map_preset.each do |coordinate_string|
      xy_hash = MapMachine.convert_string_to_coordinate_xy(coordinate_string)
      obstacle_unit = Unit.create(spawner: obstacle_spawner, attribute_health: 10, coordinate_Y: xy_hash[:y], coordinate_X: xy_hash[:x], base_health: 10, base_movement: 0, base_range: 0, base_melee: 0, base_vision: 0, base_spawn_position: coordinate_string, uuid: rand(1000000000..9999999999), colour: "#7aa9de", new: false, obstacle: true)
      initial_map_state[coordinate_string]["contents"] = obstacle_unit.uuid
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


