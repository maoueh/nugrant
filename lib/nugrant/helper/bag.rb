require 'multi_json'
require 'yaml'

require 'nugrant/bag'

module Nugrant
  module Helper
    module Bag
      def self.read(filepath, filetype, config)
        Nugrant::Bag.new(parse_data(filepath, filetype, config), config)
      end

      def self.restricted_keys()
        Nugrant::Bag.instance_methods()
      end

      private

      def self.parse_data(filepath, filetype, config)
        return if not File.exist?(filepath)

        File.open(filepath, "rb") do |file|
          return send("parse_#{filetype}", file)
        end
      rescue => error
        config.parse_error.call(filepath, error)
      end

      def self.parse_json(io)
        MultiJson.load(io.read())
      end

      def self.parse_yaml(io)
        YAML.load(io.read())
      end
    end
  end
end
