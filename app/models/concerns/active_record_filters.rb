module ActiveRecordFilters

  def filtered_api_call(model, key_array)
    self.send(model).select(key_array)
  end

end