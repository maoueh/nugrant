module Nugrant
  module Helper
    class Env

      @@DEFAULT_SCRIPT_PATH = "./nugrant2env.sh"

      ##
      # Notes on `namer`
      #
      # A namer is a lambda taking as argument an array of segments
      # that should return a string representation of those segments.
      # How the segments are transformed to a string is up to the
      # namer. By using various namer, we can change how a bag key
      # is transformed into and environment variable name. This is
      # like the strategy pattern.
      #

      ##
      # Returns the default namer, which join segments together
      # using a character and upcase the result.
      #
      # @param `char` The character used to join segments together, default to `"_"`.
      #
      # @return A lambda that will simply joins segment using the `char` argument
      #         and upcase the result.
      #
      def self.default_namer(char = "_")
        lambda do |segments|
          segments.join(char).upcase()
        end
      end

      ##
      # Returns the prefix namer, which add a prefix to segments
      # and delegate its work to another namer.
      #
      # @param prefix The prefix to add to segments.
      # @param delegate_namer A namer that will be used to transform the prefixed segments.
      #
      # @return A lambda that will simply add prefix to segments and will call
      #         the delegate_namer with those new segments.
      #
      def self.prefix_namer(prefix, delegate_namer)
        lambda do |segments|
          delegate_namer.call([prefix] + segments)
        end
      end

      def self.commands(type, bag, options = {})
        # TODO: Replace by a map type => function name
        case
        when type == :export
          export_commands(bag, options)
        when type == :unset
          unset_commands(bag, options)
        end
      end

      ##
      # Generate the list of export commands that must be
      # executed so each bag variables is export to an
      # environment variables
      #
      # @param bag The bag to export to environment variables
      #
      # @return A list of commands that can be used to
      #         export the bag to environment variables.
      #
      # Options:
      #  * :escape_value (true) => If true, escape the value to export.
      #
      #  * :namer (nil) => A block taking as options the full path of
      #                    an export variable key and return what
      #                    the name the should be exported.
      #
      # * :override (true) => If true, an export command will be put
      #                       in the list even if it already exist in
      #                       the ENV array.
      #
      def self.export_commands(bag, options = {})
        namer = options[:namer] || default_namer()
        override = options.fetch(:override, true)

        commands = []
        walk_bag(bag) do |segments, key, value|
          key = namer.call(segments)

          commands << export_command(key, value, options) if override or not ENV[key]
        end

        commands
      end

      ##
      # Generate the list of unset commands that must be
      # executed so each bag variables is unset from the
      # environment variables
      #
      # @param bag The bag to unset environment variables
      #
      # @return A list of commands that can be used to
      #         unset the bag from environment variables.
      #
      # Options:
      #  * :namer (nil) => A block taking as options the full path of
      #                    an export variable key and return what
      #                    the name the should be exported.
      #
      # * :override (true) => If true, an export command will be put
      #                       in the list even if it already exist in
      #                       the ENV array.
      #
      def self.unset_commands(bag, options = {})
        namer = options[:namer] || default_namer()
        override = options.fetch(:override, true)

        commands = []
        walk_bag(bag) do |segments, key, value|
          key = namer.call(segments)

          commands << unset_command(key, value, options) if override or not ENV[key]
        end

        commands
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
        value = self.escape(value) if options[:escape_value] == nil || options[:escape_value]

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
      #  * :type => The type of command, default to :export
      #  * :script_path => The path where to write the script, defaults to `./nugrant2env.sh`.
      #  * See commands, export_commands and unset_commands for further options.
      #
      def self.write_script(bag, options = {})
        file = File.open(File.expand_path(options[:script_path] || @@DEFAULT_SCRIPT_PATH), "w")

        file.puts("#!/bin/env sh")
        file.puts()

        write_commands(bag, options, file)
      ensure
        file.close() if file
      end

      ##
      # Creates a bash script containing the commands that are required
      # to export or unset a bunch of environment variables taken from the
      # bag.
      #
      # The
      #
      # @param bag The bag to create the script for.
      # @param io The io where to output the commands, defaults to $stdout.
      #
      # @return (side-effect) Outputs to io the commands generated.
      #
      # Options:
      #  * :type => The type of command, default to :export
      #  * See commands, export_commands and unset_commands for further options.
      #
      def self.write_commands(bag, options = {}, io = $stdout)
        commands = commands(options[:type] || :export, bag, options)

        commands.each do |command|
          io.puts(command)
        end
      end

      ##
      # Returns the escaped version of the value. The
      # escape is simple by surrounding value with "
      # and escaping " to \" so the value remains valid.
      #
      # @param value The value to escape, cannot be nil.
      def self.escape(value)
        # This surround value with " and escape " to \"
        "\"#{value.gsub(/"/, "\\\"")}\""
      end

      private

      def self.walk_bag(bag, parents = [], &block)
        commands = []

        bag.each do |key, value|
          segments = parents + [key]
          nested_bag = value.kind_of?(Nugrant::Bag)

          walk_bag(value, segments, &block) if nested_bag
          yield segments, key, value if not nested_bag
        end
      end
    end
  end
end
