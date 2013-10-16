require 'rbconfig'

module Nugrant
  class Config
    DEFAULT_PARAMS_FILENAME = ".nuparams"
    DEFAULT_PARAMS_FORMAT = :yaml

    attr_reader :params_filename, :params_format, :current_path, :user_path, :system_path

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
    #
    def initialize(options = {})
      @params_filename = options[:params_filename] || DEFAULT_PARAMS_FILENAME
      @params_format = options[:params_format] || DEFAULT_PARAMS_FORMAT

      raise ArgumentError,
        "Invalid value for :params_format. \
        The format [#{@params_format}] is currently not supported." if not [:json, :yaml].include?(@params_format)

      @current_path = File.expand_path(options[:current_path] || "./#{@params_filename}")
      @user_path = File.expand_path(options[:user_path] || "#{Config.default_user_path()}/#{@params_filename}")
      @system_path = File.expand_path(options[:system_path] || "#{Config.default_system_path()}/#{@params_filename}")
    end
  end
end
