require 'nugrant'

module Nugrant
  module Vagrant
    module Command
      class Root < ::Vagrant::Command::Base
        def initialize(arguments, environment)
          super(arguments, environment)

          @arguments, @subcommand, @subarguments = split_main_and_subcommand(arguments)

          # Change super class available arguments to main ones only
          @argv = @arguments

          @subcommands = ::Vagrant::Registry.new()
          @subcommands.register(:parameters) do
            require File.expand_path("../parameters", __FILE__)
            Parameters
          end

          @show_help = false
          @show_version = false
        end

        def create_parser()
          return OptionParser.new do |parser|
            parser.banner = "Usage: vagrant user [-h] [-v] <command> [<args>]"

            parser.separator ""
            parser.on("-h", "--help", "Print this help") do
              @show_help = true
            end

            parser.on("-v", "--version", "Print plugin version and exit.") do
              @show_version = true
            end

            parser.separator ""
            parser.separator "Available subcommands:"

            keys = []
            @subcommands.each { |key, value| keys << key.to_s }

            keys.sort.each do |key|
              parser.separator "     #{key}"
            end

            parser.separator ""
            parser.separator "For help on any individual command run `vagrant user COMMAND -h`"
          end
        end

        def execute
          parser = create_parser()
          arguments = parse_options(parser)

          return version() if @show_version
          return help(parser) if @show_help

          command_class = @subcommands.get(@subcommand.to_sym) if @subcommand
          return help(parser) if !command_class || !@subcommand

          @logger.debug("Invoking nugrant command class: #{command_class} #{@subarguments.inspect}")

          command_class.new(@subarguments, @env).execute
        end

        def help(parser)
          @env.ui.info(parser.help, :prefix => false)
        end

        def version()
          @env.ui.info("Nugrant version #{Nugrant::VERSION}", :prefix => false)
        end
      end
    end
  end
end
