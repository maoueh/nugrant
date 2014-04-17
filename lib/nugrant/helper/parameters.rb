require 'nugrant/parameters'

module Nugrant
  module Helper
    module Parameters
      def self.restricted_keys()
        methods = Nugrant::Parameters.instance_methods() + Nugrant::Bag.instance_methods()
        methods.uniq!
      end
    end
  end
end
