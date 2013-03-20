require 'pathname'
require 'nugrant'
require 'nugrant/config'
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

  if Vagrant.const_defined?(:Vagrant)
    require 'nugrant/vagrant/v2/plugin'
  end
end
