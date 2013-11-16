require 'nugrant'
require 'nugrant/helper/env'

module Nugrant
  module Vagrant
    module V2
      module Command
        class Env < ::Vagrant.plugin("2", :command)
          def initialize(arguments, environment)
            super(arguments, environment)

            @unset = false
            @script = false
            @show_help = false
          end

          def create_parser()
            return OptionParser.new do |parser|
              parser.banner = "Usage: vagrant user env [<options>]"
              parser.separator ""

              parser.separator "Outputs the commands that should be executed to export\n" +
                               "the various parameter as environment variables. By default,\n" +
                               "existing ones are overridden."
              parser.separator ""

              parser.separator "Available options:"
              parser.separator ""

              parser.on("-u", "--[no-]unset", "Generates commands needed to unset environment variables, default false") do |unset|
                @unset = unset
              end

              parser.on("-s", "--[no-]script", "Generates a bash script instead of simply showing command, default false") do |script|
                 @script = script
              end

              parser.on("-h", "--help", "Print this help") do
                @show_help = true
              end
            end
          end

          def help(parser)
            @env.ui.info(parser.help, :prefix => false)
          end

          def execute
            parser = create_parser()
            arguments = parse_options(parser)

            return help(parser) if @show_help

            @logger.debug("Nugrant 'Env'")
            with_target_vms(arguments) do |vm|
              config = vm.config.user
              parameters = config ? config.parameters : Nugrant::Parameters.new()
              bag = parameters.__all

              options = {:type => @unset ? :unset : :export}

              Helper::Env.write_commands(bag, options) if not @script
              Helper::Env.write_script(bag, options) if @script

              # No need to execute for the other VMs
              return 0
            end
          end
        end
      end
    end
  end
end
