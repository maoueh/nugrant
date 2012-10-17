class Nugrant::Config
  def initialize(options = {})
    @params_filename = options.fetch(:params_filename, ".vagrantparams")
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
