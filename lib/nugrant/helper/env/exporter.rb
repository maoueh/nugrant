require 'shellwords'

require 'nugrant/bag'
require 'nugrant/helper/env/namer'

module Nugrant
  module Helper
    module Env
      module Exporter
        DEFAULT_AUTOENV_PATH = "./.env"
        DEFAULT_SCRIPT_PATH = "./nugrant2env.sh"

        VALID_EXPORTERS = [:autoenv, :script, :terminal]

        ##
        # Returns true if the exporter name received is a valid
        # valid export, false otherwise.
        #
        # @param exporter The exporter name to check validity
        #
        # @return true if exporter is valid, false otherwise.
        def self.valid?(exporter)
          VALID_EXPORTERS.include?(exporter)
        end

        ##
        # Creates an autoenv script containing the commands that are required
        # to export or unset a bunch of environment variables taken from the
        # bag.
        #
        # @param bag The bag to create the script for.
        #
        # @return (side-effect) Creates a script file containing commands
        #                       to export or unset environment variables for
        #                       bag.
        #
        # Options:
        #  * :autoenv_path => The path where to write the script, defaults to `./.env`.
        #  * :escape_value => If true, escape the value to export (or unset), default to true.
        #  * :io => The io where the command should be written, default to nil which create the autoenv on disk.
        #  * :namer => The namer used to transform bag segments into variable name, default to Namer::default().
        #  * :override => If true, variable a exported even when the override an existing env key, default to true.
        #  * :type => The type of command, default to :export.
        #
        def self.autoenv_exporter(bag, options = {})
          io = options[:io] || (File.open(File.expand_path(options[:autoenv_path] || DEFAULT_AUTOENV_PATH), "wb"))

          terminal_exporter(bag, options.merge({:io => io}))
        ensure
          io.close() if io
        end

        ##
        # Creates a bash script containing the commands that are required
        # to export or unset a bunch of environment variables taken from the
        # bag.
        #
        # @param bag The bag to create the script for.
        #
        # @return (side-effect) Creates a script file containing commands
        #                       to export or unset environment variables for
        #                       bag.
        #
        # Options:
        #  * :escape_value => If true, escape the value to export (or unset), default to true.
        #  * :io => The io where the command should be written, default to nil which create the script on disk.
        #  * :namer => The namer used to transform bag segments into variable name, default to Namer::default().
        #  * :override => If true, variable a exported even when the override an existing env key, default to true.
        #  * :script_path => The path where to write the script, defaults to `./nugrant2env.sh`.
        #  * :type => The type of command, default to :export.
        #
        def self.script_exporter(bag, options = {})
          io = options[:io] || (File.open(File.expand_path(options[:script_path] || DEFAULT_SCRIPT_PATH), "wb"))

          io.puts("#!/bin/env sh")
          io.puts()

          terminal_exporter(bag, options.merge({:io => io}))
        ensure
          io.close() if io
        end

        ##
        # Export to terminal the commands that are required
        # to export or unset a bunch of environment variables taken from the
        # bag.
        #
        # @param bag The bag to create the script for.
        #
        # @return (side-effect) Outputs to io the commands generated.
        #
        # Options:
        #  * :escape_value => If true, escape the value to export (or unset), default to true.
        #  * :io => The io where the command should be displayed, default to $stdout.
        #  * :namer => The namer used to transform bag segments into variable name, default to Namer::default().
        #  * :override => If true, variable a exported even when the override an existing env key, default to true.
        #  * :type => The type of command, default to :export.
        #
        def self.terminal_exporter(bag, options = {})
          io = options[:io] || $stdout
          type = options[:type] || :export

          export(bag, options) do |key, value|
            io.puts(command(type, key, value, options))
          end
        end

        ##
        # Generic function to export a bag. This walk the bag,
        # for each element, it creates the key using the namer
        # and then forward the key and value to the block if
        # the variable does not override an existing environment
        # variable or if options :override is set to true.
        #
        # @param bag The bag to export.
        #
        # @return (side-effect) Yields each key and value to a block
        #
        # Options:
        #  * :namer => The namer used to transform bag parents into variable name, default to Namer::default().
        #  * :override => If true, variable a exported even when the override an existing env key, default to true.
        #
        def self.export(bag, options = {})
          namer = options[:namer] || Env::Namer.default()
          override = options.fetch(:override, true)

          variables = {}
          bag.walk do |path, key, value|
            key = namer.call(path)

            variables[key] = value if override or not ENV[key]
          end

          variables.sort().each do |key, value|
            yield key, value
          end
        end

        ##
        # Given a key and a value, return a string representation
        # of the command type requested. Available types:
        #
        #  * :export => A bash compatible export command
        #  * :unset => A bash compatible export command
        #
        def self.command(type, key, value, options = {})
          # TODO: Replace by a map type => function name
          case
          when type == :export
            export_command(key, value, options)
          when type == :unset
            unset_command(key, value, options)
          end
        end

        ##
        # Returns a string representation of the command
        # that needs to be used on the current platform
        # to export an environment variable.
        #
        # @param key The key of the environment variable to export.
        #            It cannot be nil.
        # @param value The value of the environment variable to export
        #
        # @return The export command, as a string
        #
        # Options:
        #  * :escape_value (true) => If true, escape the value to export.
        #
        def self.export_command(key, value, options = {})
          value = value.to_s()
          value = Shellwords.escape(value) if options[:escape_value] == nil || options[:escape_value]

          # TODO: Handle platform differently
          "export #{key}=#{value}"
        end

        ##
        # Returns a string representation of the command
        # that needs to be used on the current platform
        # to unset an environment variable.
        #
        # @param key The key of the environment variable to export.
        #            It cannot be nil.
        #
        # @return The unset command, as a string
        #
        def self.unset_command(key, value, options = {})
          # TODO: Handle platform differently
          "unset #{key}"
        end
      end
    end
  end
end
