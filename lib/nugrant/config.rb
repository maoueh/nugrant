require 'rbconfig'

module Nugrant
  class Config
    DEFAULT_ARRAY_MERGE_STRATEGY = :replace
    DEFAULT_PARAMS_FILENAME = ".nuparams"
    DEFAULT_PARAMS_FORMAT = :yaml
    DEFAULT_AUTO_EXPORT = false

    SUPPORTED_ARRAY_MERGE_STRATEGIES = [:concat, :extend, :replace]
    SUPPORTED_PARAMS_FORMATS = [:json, :yaml]

    attr_reader :params_filename, :params_format,
                :current_path, :user_path, :system_path,
                :array_merge_strategy, :auto_export, :auto_export_script_path,
                :key_error, :parse_error

    attr_writer :array_merge_strategy, :auto_export, :auto_export_script_path

    ##
    # Convenience method to easily accept either a hash that will
    # be converted to a Nugrant::Config object or directly a config
    # object.
    def self.convert(config = {})
      return config.kind_of?(Nugrant::Config) ? config : Nugrant::Config.new(config)
    end

    ##
    # Return the fully expanded path of the user parameters
    # default location that is used in the constructor.
    #
    def self.default_user_path()
      File.expand_path("~")
    end

    ##
    # Return the fully expanded path of the system parameters
    # default location that is used in the constructor.
    #
    def self.default_system_path()
      if Config.on_windows?
        return File.expand_path(ENV['PROGRAMDATA'] || ENV['ALLUSERSPROFILE'])
      end

      "/etc"
    end

    ##
    # Method to fix-up a received path. The fix-up do the follows
    # the following rules:
    #
    # 1. If the path is callable, call it to get the value.
    # 2. If value is nil, return default value.
    # 3. If value is a directory, return path + params_filename to it.
    # 4. Otherwise, return value
    #
    # @param path The path parameter received.
    # @param default The default path to use, can be a directory.
    # @param params_filename The params filename to append if path is a directory
    #
    # @return The fix-up path following rules defined above.
    #
    def self.fixup_path(path, default, params_filename)
      path = path.call if path.respond_to?(:call)

      path = File.expand_path(path || default)
      path = "#{path}/#{params_filename}" if ::File.directory?(path)

      path
    end

    def self.supported_array_merge_strategy(strategy)
      SUPPORTED_ARRAY_MERGE_STRATEGIES.include?(strategy)
    end

    def self.supported_params_format(format)
      SUPPORTED_PARAMS_FORMATS.include?(format)
    end

    ##
    # Return true if we are currently on a Windows platform.
    #
    def self.on_windows?()
      (RbConfig::CONFIG['host_os'].downcase =~ /mswin|mingw|cygwin/) != nil
    end

    ##
    # Creates a new config object that is used to configure an instance
    # of Nugrant::Parameters. See the list of options and how they interact
    # with Nugrant::Parameters.
    #
    # =| Options
    #  * +:params_filename+ - The filename used to fetch parameters from. This
    #                         will be appended to various default locations.
    #                         Location are system, project and current that
    #                         can be tweaked individually by using the options
    #                         below.
    #                           Defaults => ".nuparams"
    #  * +:params_format+   - The format in which parameters are to be parsed.
    #                         Presently supporting :yaml and :json.
    #                           Defaults => :yaml
    #  * +:current_path+    - The current path has the highest precedence over
    #                         any other location. It can be be used for many purposes
    #                         depending on your usage.
    #                          * A path from where to read project parameters
    #                          * A path from where to read overriding parameters for a cli tool
    #                          * A path from where to read user specific settings not to be committed in a VCS
    #                           Defaults => "./#{@params_filename}"
    #  * +:user_path+       - The user path is the location where the user
    #                         parameters should resides. The parameters loaded from this
    #                         location have the second highest precedence.
    #                           Defaults => "~/#{@params_filename}"
    #  * +:system_path+     - The system path is the location where system wide
    #                         parameters should resides. The parameters loaded from this
    #                         location have the third highest precedence.
    #                           Defaults => Default system path depending on OS + @params_filename
    #  * +:array_merge_strategy+  - This option controls how array values are merged together when merging
    #                               two Bag instances. Possible values are:
    #                                 * :replace => Replace current values by new ones
    #                                 * :extend => Merge current values with new ones
    #                                 * :concat => Append new values to current ones
    #                                Defaults => The strategy :replace.
    #  * +:key_error+     - A callback method receiving one argument, the key as a symbol, and that
    #                       deal with the error. If the callable does not
    #                       raise an exception, the result of it's execution is returned.
    #                         Defaults => A callable that throws a KeyError exception.
    #  * +:parse_error+   - A callback method receiving two arguments, the offending filename and
    #                       the error object, that deal with the error. If the callable does not
    #                       raise an exception, the result of it's execution is returned.
    #                         Defaults => A callable that returns the empty hash.
    #  * +:auto_export+               - Automatically export configuration to the specified format :autoenv or :script
    #  * +:auto_export_script_path+   - The path where to write the export script, defaults to "./nugrant2env.sh"
    #
    def initialize(options = {})
      @params_filename = options[:params_filename] || DEFAULT_PARAMS_FILENAME
      @params_format = options[:params_format] || DEFAULT_PARAMS_FORMAT
      @auto_export = options[:auto_export] || DEFAULT_AUTO_EXPORT
      @auto_export_script_path = options[:auto_export_script_path] || false # use default

      @current_path = Config.fixup_path(options[:current_path], ".", @params_filename)
      @user_path = Config.fixup_path(options[:user_path], Config.default_user_path(), @params_filename)
      @system_path = Config.fixup_path(options[:system_path], Config.default_system_path(), @params_filename)

      @array_merge_strategy = options[:array_merge_strategy] || :replace

      @key_error = options[:key_error] || Proc.new do |key|
        raise KeyError, "Undefined parameter '#{key}'"
      end

      @parse_error = options[:parse_error] || Proc.new do |filename, error|
        {}
      end

      validate()
    end

    def ==(other)
      self.class.equal?(other.class) &&
      instance_variables.all? do |variable|
        instance_variable_get(variable) == other.instance_variable_get(variable)
      end
    end

    def [](key)
      instance_variable_get("@#{key}")
    rescue
      nil
    end

    def merge(other)
      result = dup()
      result.merge!(other)
    end

    def merge!(other)
      other.instance_variables.each do |variable|
        instance_variable_set(variable, other.instance_variable_get(variable)) if instance_variables.include?(variable)
      end

      self
    end

    def to_h()
      Hash[instance_variables.map do |variable|
        [variable[1..-1].to_sym, instance_variable_get(variable)]
      end]
    end

    alias_method :to_hash, :to_h

    def validate()
      raise ArgumentError,
        "Invalid value for :params_format. \
         The format [#{@params_format}] is currently not supported." if not Config.supported_params_format(@params_format)

      raise ArgumentError,
          "Invalid value for :array_merge_strategy. \
           The array merge strategy [#{@array_merge_strategy}] is currently not supported." if not Config.supported_array_merge_strategy(@array_merge_strategy)
    end
  end
end
