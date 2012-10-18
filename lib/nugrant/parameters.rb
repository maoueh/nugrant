require 'deep_merge'
require 'ostruct'

module Nugrant
  class Parameters < Nugrant::ParameterBag
    @config = nil
    @parameters = nil
    @local_parameters = nil
    @global_parameters = nil

    def initialize(config = nil)
      if config == nil
        config = Nugrant::Config.new()
      end

      @config = config
      @parameters = load_parameters()

      super(@parameters)
    end

    def get_bag()
      @bag
    end

    def get_params()
      return @parameters
    end

    def get_local_params()
      return @local_parameters
    end

    def get_global_params()
      return @global_parameters
    end

    def load_parameters()
      @local_parameters = load_parameters_file(@config.local_params_path)
      @global_parameters = load_parameters_file(@config.global_params_path)

      if @local_parameters == nil and @global_parameters == nil
        return nil
      end

      parameters = Hash.new()
      parameters.deep_merge!(@global_parameters) if @global_parameters != nil
      parameters.deep_merge!(@local_parameters) if @local_parameters != nil

      return parameters
    end

    def load_parameters_file(file_path)
      begin
        File.open(file_path) do |file|
          return YAML::load(file)
        end
      rescue
        return nil
      end
    end
  end
end
