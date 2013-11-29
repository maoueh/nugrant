require 'minitest/autorun'

require 'nugrant/bag'
require 'nugrant/helper/env/exporter'

module Nugrant
  module Helper
    module Env
      class TestExporter < ::Minitest::Test
        def create_bag(parameters)
          return Nugrant::Bag.new(parameters)
        end

        def assert_export(expected, key, value, options = {})
          actual = Env::Exporter.command(:export, key, value, options)

          assert_equal(expected, actual)
        end

        def assert_unset(expected, key, options = {})
          actual = Env::Exporter.command(:unset, key, options)

          assert_equal(expected, actual)
        end

        def assert_autoenv_exporter(expected, bag, options = {})
          io = StringIO.new()
          Env::Exporter.autoenv_exporter(bag, options.merge({:io => io}))

          actual = io.string().split(/\r?\n/)

          assert_equal(expected, actual)
        end

        def assert_script_exporter(expected, bag, options = {})
          io = StringIO.new()
          Env::Exporter.script_exporter(bag, options.merge({:io => io}))

          actual = io.string().split(/\r?\n/)

          assert_equal(expected, actual)
        end

        def assert_terminal_exporter(expected, bag, options = {})
          io = StringIO.new()
          Env::Exporter.terminal_exporter(bag, options.merge({:io => io}))

          actual = io.string().split(/\r?\n/)

          assert_equal(expected, actual)
        end

        def assert_unset_commands(expected, bag, options = {})
          actual = Env::Exporter.unset_commands(bag, options)

          assert_equal(expected, actual)
        end

        def test_valid_exporter
          assert_equal(true, Env::Exporter.valid?(:autoenv))
          assert_equal(true, Env::Exporter.valid?(:script))
          assert_equal(true, Env::Exporter.valid?(:terminal))
          assert_equal(false, Env::Exporter.valid?(:foreman))
        end

        def test_export_command
          assert_export("export TEST=\\\"running\\ with\\ space\\\"", "TEST", "\"running with space\"")
          assert_export("export TEST=running with space", "TEST", "running with space", :escape_value => false)
        end

        def test_unset_command
          assert_unset("unset TEST", "TEST")
        end

        def test_terminal_exporter_export
          bag = create_bag({
            :level1 => {
              :level2 => {
                :first => "first with space",
                :second => "\"second\\"
              },
              :third => "third"
            },
            :existing => "downcase",
          })

          stub_env(:existing => "exist", :EXISTING => "exist") do
            assert_terminal_exporter([
              "export EXISTING=downcase",
              "export LEVEL1_LEVEL2_FIRST=first\\ with\\ space",
              "export LEVEL1_LEVEL2_SECOND=\\\"second\\\\",
              "export LEVEL1_THIRD=third",
            ], bag)

            assert_terminal_exporter([
              "export LEVEL1_LEVEL2_FIRST=first\\ with\\ space",
              "export LEVEL1_LEVEL2_SECOND=\\\"second\\\\",
              "export LEVEL1_THIRD=third",
            ], bag, :override => false)

            assert_terminal_exporter([
              "export EXISTING=downcase",
              "export LEVEL1_LEVEL2_FIRST=first with space",
              "export LEVEL1_LEVEL2_SECOND=\"second\\",
              "export LEVEL1_THIRD=third",
            ], bag, :type => :export, :override => true, :escape_value => false)

            default_namer = Env::Namer.default(".")
            prefix_namer = Env::Namer.prefix("CONFIG", default_namer)

            assert_terminal_exporter([
              "export CONFIG.EXISTING=downcase",
              "export CONFIG.LEVEL1.LEVEL2.FIRST=first with space",
              "export CONFIG.LEVEL1.LEVEL2.SECOND=\"second\\",
              "export CONFIG.LEVEL1.THIRD=third",
            ], bag, :override => true, :escape_value => false, :namer => prefix_namer)
          end
        end

        def test_terminal_exporter_unset
          bag = create_bag({
            :level1 => {
              :level2 => {
                :first => "first",
                :second => "second"
              },
              :third => "third"
            },
            :existing => "downcase",
          })

          stub_env(:existing => "exist", :EXISTING => "exist") do
            assert_terminal_exporter([
              "unset EXISTING",
              "unset LEVEL1_LEVEL2_FIRST",
              "unset LEVEL1_LEVEL2_SECOND",
              "unset LEVEL1_THIRD",
            ], bag, :type => :unset)

            assert_terminal_exporter([
              "unset LEVEL1_LEVEL2_FIRST",
              "unset LEVEL1_LEVEL2_SECOND",
              "unset LEVEL1_THIRD",
            ], bag, :override => false, :type => :unset)

            default_namer = Env::Namer.default(".")
            prefix_namer = Env::Namer.prefix("CONFIG", default_namer)

            assert_terminal_exporter([
              "unset CONFIG.EXISTING",
              "unset CONFIG.LEVEL1.LEVEL2.FIRST",
              "unset CONFIG.LEVEL1.LEVEL2.SECOND",
              "unset CONFIG.LEVEL1.THIRD",
            ], bag, :override => true, :namer => prefix_namer, :type => :unset)
          end
        end

        def test_autoenv_exporter
          bag = create_bag({
            :level1 => {
              :level2 => {
                :first => "first",
                :second => "second"
              },
              :third => "third"
            },
            :existing => "downcase",
          })

          assert_autoenv_exporter([
            "export EXISTING=downcase",
            "export LEVEL1_LEVEL2_FIRST=first",
            "export LEVEL1_LEVEL2_SECOND=second",
            "export LEVEL1_THIRD=third",
          ], bag, :type => :export)

          assert_autoenv_exporter([
            "unset EXISTING",
            "unset LEVEL1_LEVEL2_FIRST",
            "unset LEVEL1_LEVEL2_SECOND",
            "unset LEVEL1_THIRD",
          ], bag, :type => :unset)
        end

        def test_script_exporter
          bag = create_bag({
            :level1 => {
              :level2 => {
                :first => "first",
                :second => "second"
              },
              :third => "third"
            },
            :existing => "downcase",
          })

          assert_script_exporter([
            "#!/bin/env sh",
            "",
            "export EXISTING=downcase",
            "export LEVEL1_LEVEL2_FIRST=first",
            "export LEVEL1_LEVEL2_SECOND=second",
            "export LEVEL1_THIRD=third",
          ], bag, :type => :export)

          assert_script_exporter([
            "#!/bin/env sh",
            "",
            "unset EXISTING",
            "unset LEVEL1_LEVEL2_FIRST",
            "unset LEVEL1_LEVEL2_SECOND",
            "unset LEVEL1_THIRD",
          ], bag, :type => :unset)
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
end
