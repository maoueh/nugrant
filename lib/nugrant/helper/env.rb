module Nugrant
  module Helper
    class Env
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
      # * :skip_existing (false) => If true, don't add an export command
      #                             that would overwrite an existing one.
      #
      def self.export_commands(bag, options = {})
        commands = []
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
        value = self.escape(value) if options[:escape_value] == nil || options[:escape_value]

        # TODO: Handle platform differently
        "export #{key}=#{value}"
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
    end
  end
end
