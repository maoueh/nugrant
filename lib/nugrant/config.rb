module Nugrant
  class Config
    DEFAULT_PARAMS_FILENAME = ".vagrantuser"
    DEFAULT_PARAMS_FILETYPE = "json"

    attr :params_filetype, true
    attr :params_filename, false

    def initialize(options = {})
      options.delete_if { |key, value| value == nil }

      @params_filetype = options.fetch(:params_filetype, DEFAULT_PARAMS_FILETYPE)
      @params_filename = options.fetch(:params_filename, DEFAULT_PARAMS_FILENAME)
      @local_params_path = options.fetch(:local_params_path, "./#{@params_filename}")
      @global_params_path = options.fetch(:global_params_path, "~/#{@params_filename}")
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
