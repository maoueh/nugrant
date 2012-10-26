require 'deep_merge'
require 'json'
require 'ostruct'

module Nugrant
  class Parameters < Nugrant::ParameterBag
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

    def get_project_params()
      return @project_parameters
    end

    def get_user_params()
      return @user_parameters
    end

    def load_parameters()
      @project_parameters = load_parameters_file(@config.project_params_path)
      @user_parameters = load_parameters_file(@config.user_params_path)
      @system_parameters = load_parameters_file(@config.system_params_path)

      if @project_parameters == nil and @user_parameters == nil and @system_parameters == nil
        return nil
      end

      parameters = Hash.new()
      parameters.deep_merge!(@user_parameters) if @user_parameters != nil
      parameters.deep_merge!(@project_parameters) if @project_parameters != nil
      parameters.deep_merge!(@system_parameters) if @system_parameters != nil

      return parameters
    end

    def load_parameters_file(file_path)
      if not File.exists?(file_path)
        return nil
      end

      begin
        File.open(file_path, "rb") do |file|
          parsing_method = "parse_#{@config.params_filetype}"

          return send(parsing_method, file.read)
        end
      rescue => error
        throw "Could not parse the user #{@config.params_filetype} parameters file '#{file_path}': #{error}"
      end
    end

    def parse_json(data_string)
      JSON.parse(data_string)
    end

    def parse_yml(data_string)
      YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

      YAML.load(data_string)
    end
  end
end
