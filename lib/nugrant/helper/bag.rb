require 'multi_json'
require 'yaml'

require 'nugrant/bag'

module Nugrant
  module Helper
    module Bag
      def self.read(filepath, filetype, error_handler = nil)
        data = parse_data(filepath, filetype, error_handler)

        return Nugrant::Bag.new(data)
      end

      def self.parse_data(filepath, filetype, error_handler = nil)
        return if not File.exists?(filepath)

        begin
          File.open(filepath, "rb") do |file|
            parsing_method = "parse_#{filetype}"
            return send(parsing_method, file.read)
          end
        rescue => error
          if error_handler
            # TODO: Implements error handler logic
            error_handler.handle("Could not parse the user #{filetype} parameters file '#{filepath}': #{error}")
          end
        end
      end

      def self.parse_json(data_string)
        MultiJson.load(data_string)
      end

      def self.parse_yml(data_string)
        YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

        YAML.load(data_string)
      end
    end
  end
end
