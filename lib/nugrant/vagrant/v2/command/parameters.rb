require 'nugrant'
require 'nugrant/helper/yaml'
require 'nugrant/vagrant/v2/helper'

module Nugrant
  module Vagrant
    module V2
      module Command
        class Parameters < ::Vagrant.plugin("2", :command)
          def self.synopsis
            "prints parameters hierarchy as seen by Nugrant"
          end

          def initialize(arguments, environment)
            super(arguments, environment)

            @show_help = false
            @show_defaults = false
            @show_system = false
            @show_user = false
            @show_project = false
          end

          def create_parser()
            return OptionParser.new do |parser|
              parser.banner = "Usage: vagrant user parameters [<options>]"
              parser.separator ""

              parser.separator "Available options:"
              parser.separator ""

              parser.on("-h", "--help", "Print this help") do
                @show_help = true
              end

              parser.on("-d", "--defaults", "Show only defaults parameters") do
                @show_defaults = true
              end

              parser.on("-s", "--system", "Show only system parameters") do
                @show_system = true
              end

              parser.on("-u", "--user", "Show only user parameters") do
                 @show_user = true
               end

               parser.on("-p", "--project", "Show only project parameters") do
                 @show_project = true
               end

               parser.separator ""
               parser.separator "When no options is provided, the command prints the names and values \n" +
                                "of all parameters that would be available for usage in the Vagrantfile.\n" +
                                "The hierarchy of the parameters is respected, so the final values are\n" +
                                "displayed."
            end
          end

          def execute
            parser = create_parser()
            arguments = parse_options(parser)

            return help(parser) if @show_help

            @logger.debug("'Parameters' each target VM...")
            with_target_vms(arguments) do |vm|
              parameters = vm.config.user
              if not parameters
                @env.ui.info("# Vm '#{vm.name}' : unable to retrieve `config.user`, report as bug https://github.com/maoueh/nugrant/issues", :prefix => false)
                next
              end

              @env.ui.info("# Vm '#{vm.name}'", :prefix => false)

              defaults(parameters) if @show_defaults
              system(parameters) if @show_system
              user(parameters) if @show_user
              project(parameters) if @show_project

              all(parameters) if !@show_defaults && !@show_system && !@show_user && !@show_project
            end

            return 0
          end

          def help(parser)
            @env.ui.info(parser.help, :prefix => false)
          end

          def defaults(parameters)
            print_bag("Defaults", parameters.__defaults)
          end

          def system(parameters)
            print_bag("System", parameters.__system)
          end

          def user(parameters)
            print_bag("User", parameters.__user)
          end

          def project(parameters)
            print_bag("Project", parameters.__project)
          end

          def all(parameters)
            print_bag("All", parameters.__all)
          end

          def print_bag(kind, bag)
            if !bag || bag.empty?()
              print_header(kind)
              @env.ui.info(" Empty", :prefix => false)
              @env.ui.info("", :prefix => false)
              return
            end

            print_parameters(kind, {
              'config' => {
                'user' => bag.to_hash(:use_string_key => true)
              }
            })
          end

          def print_parameters(kind, hash)
            string = Nugrant::Helper::Yaml.format(hash.to_yaml, :indent => 1)
            used_restricted_keys = Helper::get_used_restricted_keys(hash, Helper::get_restricted_keys())

            print_warning(used_restricted_keys) if !used_restricted_keys.empty?()

            print_header(kind)
            @env.ui.info(string, :prefix => false)
            @env.ui.info("", :prefix => false)
          end

          def print_header(kind, length = 50)
            @env.ui.info(" #{kind.capitalize} Parameters", :prefix => false)
            @env.ui.info(" " + "-" * length, :prefix => false)
          end

          def print_warning(used_restricted_keys)
            @env.ui.info("", :prefix => false)
            @env.ui.info(" You are using some restricted keys. Method access (using .<key>) will", :prefix => false)
            @env.ui.info(" not work, only array access ([<key>]) will. Offending keys:", :prefix => false)
            @env.ui.info("   #{used_restricted_keys.join(", ")}", :prefix => false)
            @env.ui.info("", :prefix => false)
          end
        end
      end
    end
  end
end
