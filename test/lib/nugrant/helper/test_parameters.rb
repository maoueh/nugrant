require 'minitest/autorun'

require 'nugrant/bag'
require 'nugrant/helper/parameters'

module Nugrant
  module Helper
    class TestParameters < ::Minitest::Test
      def test_restricted_keys_contains_hash_ones
        keys = Helper::Parameters.restricted_keys()
        Nugrant::Bag.instance_methods.each do |method|
          assert_includes(keys, method, "Restricted keys must include Nugrant::Bag method #{method}")
        end
      end
    end
  end
end
