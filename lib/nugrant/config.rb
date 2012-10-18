module Nugrant
  class Config
    DEFAULT_PARAMS_FILENAME = ".vagrantuser"

    def initialize(options = {})
      @params_filename = options.fetch(:params_filename, DEFAULT_PARAMS_FILENAME)
      @local_params_path = options.fetch(:local_params_path, "./#{@params_filename}")
      @global_params_path = options.fetch(:global_params_path, "~/#{@params_filename}")
    end

    def params_filename()
      return @params_filename
    end

    def local_params_path()
      File.expand_path(@local_params_path)
    end

    def global_params_path()
      File.expand_path(@global_params_path)
    end

    def homedir()
      return File.expand_path("~")
    end
  end
end
