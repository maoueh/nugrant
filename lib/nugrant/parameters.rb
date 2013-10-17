require 'nugrant/bag'
require 'nugrant/helper/bag'

module Nugrant
  class Parameters
    attr_reader :__defaults, :__system, :__user, :__project, :__all

    def initialize(config = nil, defaults = nil)
      @__config = config || Config.new()

      @__defaults = defaults || Bag.new()
      @__system = Helper::Bag.read(@__config.system_params_path, @__config.params_filetype)
      @__user = Helper::Bag.read(@__config.user_params_path, @__config.params_filetype)
      @__project = Helper::Bag.read(@__config.project_params_path, @__config.params_filetype)

      __compute_all()
    end

    def [](key)
      return @__all[key]
    end

    def method_missing(method, *args, &block)
      return @__all[method]
    end

    def empty?()
      @__all.empty?()
    end

    def has?(key)
      return @__all.has?(key)
    end

    def each(&block)
      @__all.each(&block)
    end

    def defaults=(elements)
      @__defaults = Bag.new(elements)

      # When defaults change, we need to recompute parameters hierarchy
      __compute_all()
    end

    def __compute_all()
      @__all = Bag.new()
      @__all.__merge!(@__defaults)
      @__all.__merge!(@__system)
      @__all.__merge!(@__user)
      @__all.__merge!(@__project)
    end
  end
end
