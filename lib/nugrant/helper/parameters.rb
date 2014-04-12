require 'nugrant/parameters'

module Nugrant
  module Helper
    module Parameters
      def self.restricted_keys()
        Nugrant::Parameters.instance_methods()
      end
    end
  end
end
