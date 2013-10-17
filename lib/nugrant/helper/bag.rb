require 'multi_json'
require 'yaml'

require 'nugrant/bag'

module Nugrant
  module Helper
    module Bag
      def self.read(filepath, format, error_handler = nil)
        data = parse_data(filepath, format, error_handler)

        return Nugrant::Bag.new(data)
      end

      def self.parse_data(filepath, format, error_handler = nil)
        return if not File.exists?(filepath)

        begin
          File.open(filepath, "rb") do |file|
            parsing_method = "parse_#{format.to_s}"
            return send(parsing_method, file.read())
          end
        rescue => error
          if error_handler
            # TODO: Implements error handler logic
            error_handler.handle("Could not parse the user #{format.to_s} parameters file '#{filepath}': #{error}")
          end
        end
      end

      def self.parse_json(input)
        MultiJson.load(input)
      end

      def self.parse_yaml(input)
        YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

        YAML.load(input)
      end
    end
  end
end
