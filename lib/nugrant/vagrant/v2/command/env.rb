require 'nugrant'
require 'nugrant/helper/env/exporter'
require 'nugrant/parameters'

EnvExporter = Nugrant::Helper::Env::Exporter

module Nugrant
  module Vagrant
    module V2
      module Command
        class Env < ::Vagrant.plugin("2", :command)
          def self.synopsis
            "env utilities to export config.user as environment variables in host machine"
          end

          def initialize(arguments, environment)
            super(arguments, environment)

            @unset = false
            @format = :terminal
            @show_help = false
          end

          def create_parser()
            return OptionParser.new do |parser|
              parser.banner = "Usage: vagrant user env [<options>]"
              parser.separator ""

              parser.separator "Outputs the commands that should be executed to export\n" +
                               "the various parameter as environment variables. By default,\n" +
                               "existing ones are overridden. The --format argument can be used\n" +
                               "to choose in which format the variables should be displayed.\n" +
                               "Changing the format will also change where they are displayed.\n"
              parser.separator ""

              parser.separator "Available formats:"
              parser.separator "  autoenv  => Write commands to a file named `.env` in the current directory.\n" +
                               "               See https://github.com/kennethreitz/autoenv for more info."
              parser.separator "  terminal => Display commands to terminal so they can be sourced."
              parser.separator "  script   => Write commands to a bash script named `nugrant2env.sh` so it can be sourced."
              parser.separator ""

              parser.separator "Available options:"
              parser.separator ""

              parser.on("-u", "--[no-]unset", "Generates commands needed to unset environment variables, default false") do |unset|
                @unset = unset
              end

              parser.on("-f", "--format FORMAT", "Determines in what format variables are output, default to terminal") do |format|
                 @format = format.to_sym()
              end

              parser.on("-h", "--help", "Print this help") do
                @show_help = true
              end
            end
          end

          def error(message, parser)
            @env.ui.info("ERROR: #{message}", :prefix => false)
            @env.ui.info("", :prefix => false)

            help(parser)

            return 1
          end

          def help(parser)
            @env.ui.info(parser.help, :prefix => false)
          end

          def execute
            parser = create_parser()
            arguments = parse_options(parser)

            return error("Invalid format value '#{@format}'", parser) if not EnvExporter.valid?(@format)
            return help(parser) if @show_help

            @logger.debug("Nugrant 'Env'")
            with_target_vms(arguments) do |vm|
              config = vm.config.user
              parameters = config ? config : Nugrant::Parameters.new()
              bag = parameters.__all

              options = {:type => @unset ? :unset : :export}

              case
              when @format == :script
                EnvExporter.script_exporter(bag, options)
              when @format == :autoenv
                EnvExporter.autoenv_exporter(bag, options)
              when @format == :terminal
                EnvExporter.terminal_exporter(bag, options)
              end

              # No need to execute for the other VMs
              return 0
            end
          end
        end
      end
    end
  end
end
