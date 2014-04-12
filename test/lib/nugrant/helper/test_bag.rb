require 'minitest/autorun'

require 'nugrant/helper/bag'

module Nugrant
  module Helper
    class TestBag < ::Minitest::Test
      def test_restricted_keys_contains_hash_ones
        keys = Helper::Bag.restricted_keys()
        Hash.instance_methods.each do |method|
          assert_includes(keys, method, "Restricted keys must include Hash method #{method}")
        end
      end
    end
  end
end
