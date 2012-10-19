require 'nugrant'
require 'nugrant/config'
require 'nugrant/parameter_bag'
require 'nugrant/parameters'

module Nugrant
  def self.create_parameters(resource_path, local_params_filename, global_params_filename = nil)
    local_params_path = "#{resource_path}/#{local_params_filename}" if resource_path
    global_params_path = "#{resource_path}/#{global_params_filename}" if resource_path and global_params_filename

    config = Nugrant::Config.new({
      :local_params_path => local_params_path,
      :global_params_path => global_params_path
    })

    return Nugrant::Parameters.new(config)
  end
end


