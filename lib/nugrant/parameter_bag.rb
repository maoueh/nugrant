class Nugrant::ParameterBag
  def initialize(parameters)
    if parameters == nil
      return
    end

    @bag = {}
    parameters.each do |key, value|
      if not value.is_a?(Hash)
        @bag[key] = value
        next
      end

      # It is a hash, transform it into a bag
      @bag[key] = Nugrant::ParameterBag.new(value)
    end
  end

  def [](param_name)
    return get_param(param_name)
  end

  def method_missing(method, *args, &block)
    return get_param(method.to_s)
  end

  def has_param?(param_name)
    return @bag != nil && @bag.has_key?(param_name)
  end

  def get_param(param_name)
    if not has_param?(param_name)
      raise "Invalid parameters '#{param_name}'?"
    end

    return @bag[param_name]
  end

  def get_params()
    return @bag
  end
end
