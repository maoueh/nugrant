require 'nugrant'
require 'nugrant/config'
require 'nugrant/parameter_bag'
require 'nugrant/parameters'

module Nugrant
  def self.create_parameters(options)
    config = Nugrant::Config.new(options)

    return Nugrant::Parameters.new(config)
  end
end


