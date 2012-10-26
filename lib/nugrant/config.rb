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
      @project_params_path = options.fetch(:project_params_path, "./#{@params_filename}")
      @user_params_path = options.fetch(:user_params_path, "~/#{@params_filename}")
    end

    def project_params_path()
      File.expand_path(@project_params_path)
    end

    def user_params_path()
      File.expand_path(@user_params_path)
    end

    def homedir()
      return File.expand_path("~")
    end
  end
end
