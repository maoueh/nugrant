require 'pathname'

require 'nugrant'
require 'nugrant/bag'
require 'nugrant/vagrant/v2/config/user'

module Nugrant
  module Vagrant
    module V2
      class Helper

        ##
        # The project path is the path where the top-most (loaded last)
        # Vagrantfile resides. It can be considered the project root for
        # this environment.
        #
        # Copied from `lib\vagrant\environment.rb#532` (tag: v1.6.2)
        #
        # @return [String] The project path to use.
        #
        def self.find_project_path()
          vagrantfile_name = ENV["VAGRANT_VAGRANTFILE"]

          root_finder = lambda do |path|
            vagrantfile = find_vagrantfile(path, vagrantfile_name)

            return path if vagrantfile
            return nil if path.root? || !File.exist?(path)

            root_finder.call(path.parent)
          end

          root_finder.call(get_vagrant_working_directory())
        end

        ##
        # Finds the Vagrantfile in the given directory.
        #
        # Copied from `lib\vagrant\environment.rb#732` (tag: v1.6.2)
        #
        # @param [Pathname] path Path to search in.
        # @return [Pathname]
        #
        def self.find_vagrantfile(search_path, filenames = nil)
          filenames ||= ["Vagrantfile", "vagrantfile"]
          filenames.each do |vagrantfile|
            current_path = search_path.join(vagrantfile)
            return current_path if current_path.file?
          end

          nil
        end

        ##
        # Returns Vagrant working directory to use.
        #
        # Copied from `lib\vagrant\environment.rb#80` (tag: v1.6.2)
        #
        # @return [Pathname] The working directory to start search in.
        #
        def self.get_vagrant_working_directory()
          cwd = nil

          # Set the default working directory to look for the vagrantfile
          cwd ||= ENV["VAGRANT_CWD"] if ENV.has_key?("VAGRANT_CWD")
          cwd ||= Dir.pwd
          cwd = Pathname.new(cwd)

          if !cwd.directory?
            raise Errors::EnvironmentNonExistentCWD, cwd: cwd.to_s
          end

          cwd = cwd.expand_path
        end

        def self.get_restricted_keys()
          bag_methods = Nugrant::Bag.instance_methods
          parameters_methods = V2::Config::User.instance_methods

          (bag_methods | parameters_methods).map(&:to_s)
        end

        def self.get_used_restricted_keys(hash, restricted_keys)
          keys = []
          hash.each do |key, value|
            keys << key if restricted_keys.include?(key)
            keys += get_used_restricted_keys(value, restricted_keys) if value.kind_of?(Hash)
          end

          keys.uniq
        end
      end
    end
  end
end
