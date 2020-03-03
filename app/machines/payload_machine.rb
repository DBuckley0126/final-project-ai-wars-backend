module PayloadMachine

  def self.add_payload(turn, unit)
    payload_hash = {
      base_vision: [],
      pixeling_vision: [],
      game_data: {},
      skill_points: {},
      pixeling_data: {
        health: 0,
        coordinate_X: 0,
        coordinate_Y: 0,
        target_coordinate_string: "nil",
        current_coordinate_path: [],
        current_coordinate_string: "nil"
      }
    }

    pixeling_data = PayloadMachine.get_pixeling_data(unit)
    if pixeling_data
      payload_hash[:pixeling_data] = pixeling_data
    end

    game_data = PayloadMachine.get_game_data(turn, unit)
    if game_data
      payload_hash[:game_data] = game_data
    end

    pixeling_vision = PayloadMachine.get_pixeling_vision(turn, unit)
    if pixeling_vision
      payload_hash[:pixeling_vision] = pixeling_vision
    end

    base_vision = PayloadMachine.get_base_vision(turn, unit)
    if base_vision
      payload_hash[:base_vision] = base_vision
    end

    pixeling_skill_points = PayloadMachine.get_skill_points(unit.spawner)
    if pixeling_skill_points
      payload_hash[:skill_points] = pixeling_skill_points
    end
    unit.data_set = payload_hash
    unit.save
  end

  def self.add_general_payload(turn, spawner)
    payload_hash = {
      base_vision: [],
      pixeling_vision: [],
      game_data: {},
      skill_points: {},
      pixeling_data: {
        health: spawner.skill_points["health"],
        coordinate_X: 0,
        coordinate_Y: 0,
        target_coordinate_string: "nil",
        previous_coordinate_path: [],
        current_coordinate_string: "nil"
      }
    }

    game_data = PayloadMachine.get_game_data(turn, spawner)
    if game_data
      payload_hash[:game_data] = game_data
    end

    base_vision = PayloadMachine.get_base_vision(turn, spawner)
    if base_vision
      payload_hash[:base_vision] = base_vision
    end

    spawner_skill_points = PayloadMachine.get_skill_points(spawner)
    if spawner_skill_points
      payload_hash[:skill_points] = spawner_skill_points
    end

    spawner.default_data_set = payload_hash
    spawner.save
  end

  def self.get_pixeling_data(unit)
      {
        health: unit.attribute_health,
        coordinate_X: unit.coordinate_X,
        coordinate_Y: unit.coordinate_Y,
        target_coordinate_string: unit.target_coordinate_string,
        current_coordinate_path: unit.current_path,
        current_coordinate_string: unit.string_coordinates
      }
  end

  def self.get_skill_points(spawner)
    {
      health: spawner.skill_points["health"],
      melee: spawner.skill_points["melee"],
      movement: spawner.skill_points["movement"],
      range: spawner.skill_points["range"],
      vision: spawner.skill_points["vision"],
    }
  end

  def self.get_game_data(turn, unit_or_spawner)
    output_hash = {}

    game = turn.game
    user_type = unit_or_spawner.user_type

    output_hash[:turn_count] = game.turn_count

    output_hash[:active_friendly_pixelings] = Unit.find_all_friendly_units(turn).map do |friendly_unit|
      {
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
    end

    output_hash[:active_enemy_pixelings_count] = Unit.find_all_enemy_units(turn).length

    if user_type === "host_user"
      output_hash[:friendly_base_health] = game.host_user_base_health
      output_hash[:enemy_base_health] = game.join_user_base_health
    else
      output_hash[:friendly_base_health] = game.join_user_base_health
      output_hash[:enemy_base_health] = game.host_user_base_health
    end

    output_hash
  end

  def self.get_pixeling_vision(turn, unit)
    output_hash = {}

    # Get friendly units within vision and sort by distance
    friendly_unit_array = []
    Unit.find_all_friendly_units(turn).each do |friendly_unit|
      distance_between = unit.distance(friendly_unit.string_coordinates)

      if friendly_unit != unit && distance_between <= unit.base_vision
        friendly_unit_array << {
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
      end
    end
    sorted_friendly_unit_array = friendly_unit_array.sort_by { |friendly_unit| friendly_unit[:distance]}
    output_hash[:friendly_pixelings] = sorted_friendly_unit_array

    # Get enemy units within vision and sort by distance
    enemy_unit_array = []
    Unit.find_all_enemy_units(turn).each do |enemy_unit|
      distance_between = unit.distance(enemy_unit.string_coordinates)

      if distance_between <= unit.base_vision
        enemy_unit_array << {
          distance: distance_between,
          health: enemy_unit.attribute_health,
          coordinate_Y: enemy_unit.coordinate_Y,
          coordinate_X: enemy_unit.coordinate_X,
          string_coordinate: enemy_unit.string_coordinates
        }
      end
    end
    sorted_enemy_unit_array = enemy_unit_array.sort_by { |enemy_unit| enemy_unit[:distance]}
    output_hash[:enemy_pixelings] = sorted_enemy_unit_array

    # Get obstacles within vision and sort by distance
    obstacle_array = []
    Unit.find_all_obstacles(turn).each do |obstacle|
      distance_between = unit.distance(obstacle.string_coordinates)

      if distance_between <= unit.base_vision
        obstacle_array << {
          distance: distance_between,
          health: obstacle.attribute_health,
          coordinate_Y: obstacle.coordinate_Y,
          coordinate_X: obstacle.coordinate_X,
          string_coordinate: obstacle.string_coordinates
        }
      end
    end
    sorted_obstacle_array = obstacle_array.sort_by { |obstacle| obstacle[:distance]}
    output_hash[:obstacles] = sorted_obstacle_array

    output_hash
  end

  def self.get_base_vision(turn, unit_or_spawner)
    game = turn.game

    user_type = unit_or_spawner.user_type

    output_array = []

    if user_type === "host_user"
      unit_array = game.host_user_base_vision

      unit_array.each do |base_unit|
        if base_unit.user_type === "join_user"
          output_array << {
            friendly: false,
            health: base_unit.attribute_health,
            coordinate_Y: base_unit.coordinate_Y,
            coordinate_X: base_unit.coordinate_X,
            string_coordinate: base_unit.string_coordinates
          }
        else
          output_array << {
            friendly: true,
            spawner_name: base_unit.spawner.spawner_name,
            health: base_unit.attribute_health,
            coordinate_Y: base_unit.coordinate_Y,
            coordinate_X: base_unit.coordinate_X,
            base_health: base_unit.base_health,
            base_melee: base_unit.base_melee,
            base_movement: base_unit.base_movement,
            base_range: base_unit.base_range,
            base_vision: base_unit.base_vision,
            base_spawn_position: base_unit.base_spawn_position,
            string_coordinate: base_unit.string_coordinates
          }
        end
      end
    else
      unit_array = game.join_user_base_vision

      unit_array.each do |base_unit|
        if base_unit.user_type === "host_user"
          output_array << {
            friendly: false,
            health: base_unit.attribute_health,
            coordinate_Y: base_unit.coordinate_Y,
            coordinate_X: base_unit.coordinate_X,
            string_coordinate: base_unit.string_coordinates
          }
        else
          output_array << {
            friendly: true,
            spawner_name: base_unit.spawner.spawner_name,
            health: base_unit.attribute_health,
            coordinate_Y: base_unit.coordinate_Y,
            coordinate_X: base_unit.coordinate_X,
            base_health: base_unit.base_health,
            base_melee: base_unit.base_melee,
            base_movement: base_unit.base_movement,
            base_range: base_unit.base_range,
            base_vision: base_unit.base_vision,
            base_spawn_position: base_unit.base_spawn_position,
            string_coordinate: base_unit.string_coordinates
          }
        end
      end
    end

    output_array 
  end

end

