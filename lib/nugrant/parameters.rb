require 'deep_merge'
require 'json'
require 'ostruct'
require 'yaml'

require 'nugrant/bag'

module Nugrant
  class Parameters < Nugrant::Bag
    attr_reader :defaults, :system, :user, :project, :all

    def initialize(config = nil)
      if config == nil
        config = Nugrant::Config.new()
      end

      @config = config

      @defaults = nil
      @system = parse_parameters(@config.system_params_path)
      @user = parse_parameters(@config.user_params_path)
      @project = parse_parameters(@config.project_params_path)

      @all = compute_all()
    end

    def defaults=(parameters)
      @defaults = parameters

      # When defaults change, we need to recompute parameters hierarchy
      compute_all()
    end

    def compute_all()
      @all = Hash.new()
      @all.deep_merge!(@defaults) if @defaults != nil
      @all.deep_merge!(@system) if @system != nil
      @all.deep_merge!(@user) if @user != nil
      @all.deep_merge!(@project) if @project != nil

      self.recompute(@all)

      return @all
    end

    def parse_parameters(file_path)
      data = parse_data(file_path)
      if data == nil || !data.kind_of?(Hash)
        return
      end

      restricted_key = has_restricted_keys?(data)
      if restricted_key
        raise ArgumentError, "The key '#{restricted_key}' has restricted usage and cannot be defined"
      end

      return data
    end

    def parse_data(file_path)
      return if not File.exists?(file_path)

      begin
        File.open(file_path, "rb") do |file|
          parsing_method = "parse_#{@config.params_filetype}"
          return send(parsing_method, file.read)
        end
      rescue => error
        # TODO: log this message "Could not parse the user #{@config.params_filetype} parameters file '#{file_path}': #{error}"
      end
    end

    def parse_json(data_string)
      JSON.parse(data_string)
    end

    def parse_yml(data_string)
      YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

      YAML.load(data_string)
    end

    def has_restricted_keys?(parameters)
      parameters.each do |key, value|
        if key == "defaults"
          return "defaults"
        end

        if value.is_a?(Hash)
          result = has_restricted_keys?(value)
          return result if result
        end
      end

      return false
    end
  end
end
