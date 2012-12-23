require 'nugrant'
require 'nugrant/config'
require 'nugrant/parameter_bag'
require 'nugrant/parameters'

unless defined?(KeyError)
  class KeyError < IndexError
  end
end

module Nugrant
  def self.create_parameters(options)
    config = Nugrant::Config.new(options)

    return Nugrant::Parameters.new(config)
  end
end
