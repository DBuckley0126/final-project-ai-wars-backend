module DockerTestMachine
  def self.unit_movement_test(returned_hash)
    returned_hash_copy = returned_hash

    error_array = []
    critical_error = false

    case true
        #CHECKS FOR HASH PRESENCE
      when !defined?(returned_hash)
        critical_error = true
        error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return value is undefined, needs to be a hash with required keys"}
        
      when returned_hash == nil
        critical_error = true
        error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return value is nil, needs to be a hash with required keys"}
  
      when !returned_hash == nil && returned_hash_copy.empty?
        critical_error = true
        error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash is empty, needs required keys"}
    end

    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    end

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:limit, :target, :stop, :target_string)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Movement return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true
    #CHECKS HASH CONTENTS - WARNINGS  
    when filtered_returned_hash.key?(:limit) && rfiltered_returned_hash[:limit].is_a?(Integer)
      filtered_returned_hash.delete(:limit)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Movement return hash does not contain a Integer within [:limit]."}

    #CHECKS HASH CONTENTS - CRITICAL  
    when !filtered_returned_hash.key?(:target)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain [:target] key."}
    
    when filtered_returned_hash.key?(:target) && !filtered_returned_hash[:target].key?(:X)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain [:X] key within [:target]."}

    when filtered_returned_hash.key?(:target) && !filtered_returned_hash[:target].key?(:Y)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain [:Y] key within [:target]."}

    when filtered_returned_hash.key?(:target) && filtered_returned_hash[:target].key?(:Y) && !filtered_returned_hash[:target][:Y].is_a?(Integer)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain a Integer within [:Y]."}

    when filtered_returned_hash.key?(:target) && filtered_returned_hash[:target].key?(:Y) && !filtered_returned_hash[:target][:X].is_a?(Integer)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain a Integer within [:X]."}
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
    
  end


  def self.unit_melee_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:direction)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Melee return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true 

    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:direction) && !["forward", "backwards", "left", "right"].include?(filtered_returned_hash[:direction])
      filtered_returned_hash.delete(:direction, :attack, :damage_limit)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Melee return hash does not contain a valid direction within [:direction]."}
    end

    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
  end

  def self.unit_range_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:direction, :attack, :damage_limit, :range_limit)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Range return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true
    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:direction) && !["forward", "backwards", "left", "right"].include?(filtered_returned_hash[:direction])
      filtered_returned_hash.delete(:direction)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Range return hash does not contain a valid direction within [:direction]."}
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
  end

  def self.unit_spawn_position_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:Y)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Range return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true
    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:Y) && !filtered_returned_hash[:Y].is_a?(Integer)
      filtered_returned_hash.delete(:Y)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Spawn Position return hash does not contain a valid Integer for [:Y]."}
    
    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:Y) && filtered_returned_hash[:Y].is_a?(Integer) && (filtered_returned_hash[:Y] > 50 || filtered_returned_hash[:Y] < 1)
      filtered_returned_hash.delete(:Y)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Spawn Position return value #{filtered_returned_hash[:Y]} for [:Y] is not within the valid range of (1..50)."}
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
  end

  def self.unit_vision_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:active, :limit)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Vision return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true
    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:limit) && !filtered_returned_hash[:limit].is_a?(Integer)
      filtered_returned_hash.delete(:limit)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Vision return hash does not contain a valid Integer within [:limit]."}
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
  end

  def self.unit_health_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    # REMOVES UNALLOWED KEYS FROM FIRST LEVEL 
    filtered_returned_hash = returned_hash_copy.slice(:reduce_health)
    if filtered_returned_hash.length < returned_hash_copy.length
      removed_keys_array = returned_hash_copy.merge(filtered_returned_hash) { |_k, v1, v2| v1 == v2 ? nil : :different }.compact.keys
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Health return hash contains unallowed keys, #{removed_keys_array} will be removed."}
    end

    case true
    when !filtered_returned_hash.empty? && filtered_returned_hash.key?(:reduce_health) && !filtered_returned_hash[:reduce_health].is_a?(Integer)
      filtered_returned_hash.delete(:reduce_health)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Health return hash does not contain a valid Integer within [:reduce_health]."}
    end

    
    if critical_error
      return {test_results: "FAIL", error_type: "CRITICAL HASH REQUIREMENT", message: nil, error_payload: error_array, hash_payload: []}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: filtered_returned_hash}
    end
  end


end