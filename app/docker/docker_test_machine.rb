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
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: {}}
    end

    case true
    #CHECKS HASH CONTENTS - WARNINGS  
    when returned_hash_copy.key?(:limit) && returned_hash_copy[:limit].is_a?(Integer)
      returned_hash_copy.delete(:limit)
      error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Movement return hash does not contain a Integer within 'limit'."}

    #CHECKS HASH CONTENTS - CRITICAL  
    when !returned_hash_copy.key?(:target)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain 'target' key."}
    
    when returned_hash_copy.key?(:target) && !returned_hash_copy[:target].key?(:X)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain 'X' key within 'target'."}

    when returned_hash_copy.key?(:target) && !returned_hash_copy[:target].key?(:Y)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain 'Y' key within 'target'."}

    when returned_hash_copy.key?(:target) && returned_hash_copy[:target].key?(:Y) && !returned_hash_copy[:target][:Y].is_a?(Integer)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain a Integer within 'Y'."}

    when returned_hash_copy.key?(:target) && returned_hash_copy[:target].key?(:Y) && !returned_hash_copy[:target][:X].is_a?(Integer)
      critical_error = true
      error_array << {completed_cycle: false, error_type: "ERROR", error_message: "Movement return hash does not contain a Integer within 'X'."}
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: returned_hash_copy}
    end
    
  end


  def self.unit_melee_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false
    if !returned_hash_copy.empty?
      if returned_hash_copy.key?(:direction)
        if !["foward", "behind", "left", "right"].include? returned_hash_copy[:direction]
          returned_hash_copy.delete(:direction)
          error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Melee return hash does not contain a valid direction within 'direction'."}
        end
      end
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: returned_hash_copy}
    end
  end

  def self.unit_range_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false
    if !returned_hash_copy.empty?
      if returned_hash_copy.key?(:direction)
        if !["foward", "behind", "left", "right"].include? returned_hash_copy[:direction]
          returned_hash_copy.delete(:direction)
          error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Range return hash does not contain a valid direction within 'direction'."}
        end
      end
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: returned_hash_copy}
    end
  end

  def self.unit_vision_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false
    
    if critical_error
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: {}}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: returned_hash_copy}
    end
  end

  def self.unit_health_test(returned_hash)
    returned_hash_copy = returned_hash

    if returned_hash == nil || !defined?(returned_hash)
      returned_hash_copy = {}
    end

    error_array = []
    critical_error = false

    if !returned_hash_copy.empty?
      if returned_hash_copy.key?(:reduce_health) && returned_hash_copy[:reduce_health].is_a?(Integer)
        returned_hash_copy.delete(:reduce_health)
        error_array << {completed_cycle: true, error_type: "WARNING", error_message: "Health return hash does not contain a valid Integer within 'reduce_health'."}
      end
    end
    
    if critical_error
      return {test_results: "FAIL", error_type: "Critical hash requirement", message: nil, error_payload: error_array, hash_payload: []}
    else
      return {test_results: "PASS", error_type: nil, message: nil, error_payload: error_array, hash_payload: returned_hash_copy}
    end
  end




end