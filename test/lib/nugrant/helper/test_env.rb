require 'test/unit'

require 'nugrant/bag'
require 'nugrant/helper/env'

module Nugrant
  module Helper
    class TestEnv < Test::Unit::TestCase
      def create_bag(parameters)
        return Nugrant::Bag.new(parameters)
      end

      def assert_export(expected, key, value, options = {})
        actual = Helper::Env.export_command(key, value, options)

        assert_equal(expected, actual)
      end

      def assert_unset(expected, key, options = {})
        actual = Helper::Env.unset_command(key, options)

        assert_equal(expected, actual)
      end

      def assert_export_commands(expected, bag, options = {})
        actual = Helper::Env.export_commands(bag, options)

        assert_equal(expected, actual)
      end

      def assert_unset_commands(expected, bag, options = {})
        actual = Helper::Env.unset_commands(bag, options)

        assert_equal(expected, actual)
      end

      def test_export_command
        assert_export("export TEST=\\\"running\\ with\\ space\\\"", "TEST", "\"running with space\"")
        assert_export("export TEST=running with space", "TEST", "running with space", :escape_value => false)
      end

      def test_export_commands
        bag = create_bag({
          :existing => "downcase",
          :level1 => {
            :level2 => {
              :first => "first with space",
              :second => "\"second\\"
            },
            :third => "third"
          }
        })

        stub_env(:existing => "exist", :EXISTING => "exist") do
          assert_export_commands([
            "export EXISTING=downcase",
            "export LEVEL1_LEVEL2_FIRST=first\\ with\\ space",
            "export LEVEL1_LEVEL2_SECOND=\\\"second\\\\",
            "export LEVEL1_THIRD=third",
          ], bag)

          assert_export_commands([
            "export LEVEL1_LEVEL2_FIRST=first\\ with\\ space",
            "export LEVEL1_LEVEL2_SECOND=\\\"second\\\\",
            "export LEVEL1_THIRD=third",
          ], bag, :override => false)

          assert_export_commands([
            "export EXISTING=downcase",
            "export LEVEL1_LEVEL2_FIRST=first with space",
            "export LEVEL1_LEVEL2_SECOND=\"second\\",
            "export LEVEL1_THIRD=third",
          ], bag, :override => true, :escape_value => false)

          default_namer = Helper::Env.default_namer(".")
          prefix_namer = Helper::Env.prefix_namer("CONFIG", default_namer)

          assert_export_commands([
            "export CONFIG.EXISTING=downcase",
            "export CONFIG.LEVEL1.LEVEL2.FIRST=first with space",
            "export CONFIG.LEVEL1.LEVEL2.SECOND=\"second\\",
            "export CONFIG.LEVEL1.THIRD=third",
          ], bag, :override => true, :escape_value => false, :namer => prefix_namer)
        end
      end

      def test_unset_command
        assert_unset("unset TEST", "TEST")
      end

      def test_unset_commands
        bag = create_bag({
          :existing => "downcase",
          :level1 => {
            :level2 => {
              :first => "first",
              :second => "second"
            },
            :third => "third"
          }
        })

        stub_env(:existing => "exist", :EXISTING => "exist") do
          assert_unset_commands([
            "unset EXISTING",
            "unset LEVEL1_LEVEL2_FIRST",
            "unset LEVEL1_LEVEL2_SECOND",
            "unset LEVEL1_THIRD",
          ], bag)

          assert_unset_commands([
            "unset LEVEL1_LEVEL2_FIRST",
            "unset LEVEL1_LEVEL2_SECOND",
            "unset LEVEL1_THIRD",
          ], bag, :override => false)

          default_namer = Helper::Env.default_namer(".")
          prefix_namer = Helper::Env.prefix_namer("CONFIG", default_namer)

          assert_unset_commands([
            "unset CONFIG.EXISTING",
            "unset CONFIG.LEVEL1.LEVEL2.FIRST",
            "unset CONFIG.LEVEL1.LEVEL2.SECOND",
            "unset CONFIG.LEVEL1.THIRD",
          ], bag, :override => true, :namer => prefix_namer)
        end
      end

      def replace_env(variables)
        ENV.clear()

        variables = Hash[variables.map do |name, value|
          [name.to_s, value]
        end]

        ENV.update(variables)
      end

      def stub_env(new = {})
        old = ENV.to_hash()

        replace_env(new)
        yield

      ensure
        replace_env(old)
      end
    end
  end
end
