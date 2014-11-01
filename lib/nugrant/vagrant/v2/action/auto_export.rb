require 'nugrant'
require 'nugrant/helper/env/exporter'
require 'nugrant/parameters'

EnvExporter = Nugrant::Helper::Env::Exporter

module Nugrant
  module Vagrant
    module V2
      module Action
        class AutoExport
          def initialize(app, env)
            @app = app
            @config = env[:machine].env.vagrantfile.config
          end

          def call(env)
            return @app.call(env) if not @config.user.auto_export

            options = {
              :type => :export,
              :script_path => @config.user.auto_export_script_path
            }

            Array(@config.user.auto_export).each do |exporter|
              if exporter == :terminal or not EnvExporter.valid?(exporter)
                env[:ui].warn("ERROR: Invalid config.user.auto_export value '#{format}'", :prefix => false)
                next
              end

              env[:ui].info("Configuration exported '#{format}'", :prefix => false)

              case
              when format == :script
                EnvExporter.script_exporter(@config.user.__all, options)
              when format == :autoenv
                EnvExporter.autoenv_exporter(@config.user.__all, options)
              end
            end
          end
        end
      end
    end
  end
end
