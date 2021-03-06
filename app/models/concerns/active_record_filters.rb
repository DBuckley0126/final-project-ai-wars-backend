module ActiveRecordFilters

  def filtered_api_call(model, key_array)
    model = self.send(model)
    if !model
      return
    end
    hash = Hash.new
    key_array.each do |key|
      hash[key] = model.send(key)
    end
    return hash
  end

end