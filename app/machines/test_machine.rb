module TestMachine
  def self.initial_class_security_test(codeString)

    regex_tests = [
      {regex: /\b(?:\s*send)\b/i, test: "Should not contain 'send'"},
      {regex: /\b(?:\s*Kernal)\b/i, test: "Should not contain 'Kernal'"},
      {regex: /\b(?:\s*exec)\b/i, test: "Should not contain 'Kernal'"},
      {regex: /\b(?:\s*system)\b/i, test: "Should not contain 'system'"},
      {regex: /\b(?:\s*fork)\b/i, test: "Should not contain 'fork'"},
      {regex: /\b(?:\s*load)\b/i, test: "Should not contain 'load'"},
      {regex: /\b(?:\s*autoload)\b/i, test: "Should not contain 'autoload'"},
      {regex: /\b(?:\s*require)\b/i, test: "Should not contain 'require'"},
      {regex: /\b(?:\s*DL)\b/i, test: "Should not contain 'DL'"},
      {regex: /\b(?:\s*Fiddle)\b/i, test: "Should not contain 'Fiddle'"},
      {regex: /\b(?:\s*public_send)\b/i, test: "Should not contain 'public_send'"},
      {regex: /\b(?:\s*__send__)\b/i, test: "Should not contain '__send__'"},
      {regex: /\b(?:\s*instance_eval)\b/i, test: "Should not contain 'instance_eval'"},
      {regex: /\b(?:\s*eval)\b/i, test: "Should not contain 'eval'"},
      {regex: /\b(?:\s*class_exec)\b/i, test: "Should not contain 'class_exec'"},
      {regex: /\b(?:\s*instance_exec)\b/i, test: "Should not contain 'instance_exec'"},
      {regex: /\b(?:\s*alias_method)\b/i, test: "Should not contain 'alias_method'"},
      {regex: /\b(?:\s*Module)\b/i, test: "Should not contain 'Module'"},
      {regex: /\b(?:\s*module_eval)\b/i, test: "Should not contain 'module_eval'"},
      {regex: /\b(?:\s*module_exec)\b/i, test: "Should not contain 'module_exec'"},
      {regex: /\b(?:\s*class_eval)\b/i, test: "Should not contain 'class_eval'"},
      {regex: /\b(?:\s*exit!)\b/i, test: "Should not contain 'exit!'"},
      {regex: /\b(?:\s*ssl_client)\b/i, test: "Should not contain 'ssl_client'"},
      {regex: /\b(?:\s*ssl_context)\b/i, test: "Should not contain 'ssl_context'"},
      {regex: /\b(?:\s*SSLContext)\b/i, test: "Should not contain 'SSLContext'"},
      {regex: /\b(?:\s*SSL)\b/i, test: "Should not contain 'SSL'"},
      {regex: /\b(?:\s*SSLSocket)\b/i, test: "Should not contain 'SSLSocket'"},
      {regex: /\b(?:\s*tcp_client)\b/i, test: "Should not contain 'tcp_client'"},
      {regex: /\b(?:\s*connect)\b/i, test: "Should not contain 'connect'"},
      {regex: /\b(?:\s*OpenSSL)\b/i, test: "Should not contain 'OpenSSL'"},
      {regex: /\b(?:\s*add_file)\b/i, test: "Should not contain 'add_file'"},
      {regex: /\b(?:\s*add_cert)\b/i, test: "Should not contain 'add_cert'"},
      {regex: /\b(?:\s*add_path)\b/i, test: "Should not contain 'add_path'"},
      {regex: /\b(?:\s*set_default_path)\b/i, test: "Should not contain 'set_default_path'"},
      {regex: /\b(?:\s*X509)\b/i, test: "Should not contain 'X509'"},
      {regex: /\b(?:\s*Certificate)\b/i, test: "Should not contain 'Certificate'"},
      {regex: /\b(?:\s*DEFAULT_CERT_AREA)\b/i, test: "Should not contain 'DEFAULT_CERT_AREA'"},
      {regex: /\b(?:\s*Marshal)\b/i, test: "Should not contain 'Marshal'"},
      {regex: /\b(?:\s*YAML)\b/i, test: "Should not contain 'YAML'"},
      {regex: /\b(?:\s*SafeYAML)\b/i, test: "Should not contain 'SafeYAML'"},
      {regex: /\b(?:\s*JSON)\b/i, test: "Should not contain 'JSON'"},
      {regex: /\b(?:\s*%x)\b/i, test: "Should not contain '%x'"},
      {regex: /`/i, test: "Should not contain 'JSON'"}

    ]

    begin
      regex_tests.each do |regex_test|
        match_object = codeString.match(regex_test[:regex])
        if match_object
          raise SecurityError.new(regex_test[:test])
        end
      end
      match_object_for_class = codeString.match(/\b(?:\s*class\s\s*Pixeling)\b/)
      if !match_object_for_class
        raise SecurityError.new("Should contain 'class Pixeling")
      end
      match_object_for_end = codeString.match(/\b(?:\s*end)\b/i)
      if !match_object_for_end
        raise SecurityError.new("Should contain 'end")
      end
    rescue SecurityError => error
      return {test_results: "FAIL", error_type: "Failed Initial class security test", message: error.message}
    end
     
    return {test_results: "PASS", error_type: nil, message: nil}

  end

  def self.turn_payload_content_check(turn_payload)
    begin
      if !turn_payload["new_spawner_class"].is_a?(String)

        raise StandardError.new("turn_payload.new_spawner_class is not a type of String")

      elsif !turn_payload["new_spawner_skills"].key?("melee") || 
        !turn_payload["new_spawner_skills"].key?("range") ||
        !turn_payload["new_spawner_skills"].key?("vision") || 
        !turn_payload["new_spawner_skills"].key?("health") || 
        !turn_payload["new_spawner_skills"].key?("movement")
      
        raise StandardError.new("turn_payload['new_spawner_skills'] does not have all the required skills")

      elsif turn_payload["new_spawner_skills"]["melee"] + 
        turn_payload["new_spawner_skills"]["range"] + 
        turn_payload["new_spawner_skills"]["vision"] + 
        turn_payload["new_spawner_skills"]["health"] + 
        turn_payload["new_spawner_skills"]["movement"] > 10

        raise StandardError.new("turn_payload['new_spawner_skills'] does not equal 10 or below")
      else
         return {test_results: "PASS", error_type: nil, message: nil}
      end
    rescue StandardError => error
      return {test_results: "FAIL", error_type: "SEVER_ERROR: Failed payload test", message: error.message}
    end
  end
end