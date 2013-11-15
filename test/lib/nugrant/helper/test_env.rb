require 'test/unit'

require 'nugrant/helper/env'

module Nugrant
  module Helper
    class TestEnv < Test::Unit::TestCase
      def assert_export(expected, key, value, options = {})
        actual = Helper::Env.export_command(key,  value, options)

        assert_equal(expected, actual)
      end

      def test_escape_value
        assert_equal("\"value\"", Helper::Env.escape("value"))
        assert_equal("\"\\\"value\\\"\"", Helper::Env.escape("\"value\""))
      end

      def test_export_command
        assert_export("export TEST=\"\\\"running\\\"\"", "TEST", "\"running\"")
        assert_export("export TEST=running", "TEST", "running", :escape_value => false)
      end
    end
  end
end
