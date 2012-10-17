# Nugrant

Vagrant plugin that brings user specific configuration
options. It will enable a `.vagrantparams` at different
location that will get imported into the main vagrant
config.

For example, let say the git repository you want to
expose is not located under the root folder of
your `Vagrantfile`. That means you will need to specify
the an absolute host path to share the folder on
the guest vm.

You could have something like this in your `Vagrantfile`:

    Vagrant::Config.run do |config|
        config.vm.share_folder "git", "/git", "/home/user/work/git"
    end

However, what happens when multiple developers
need to share the same `Vagrantfile`? This is the main
use case this plugin tries to save.

## Installation

Add this line to your application's Gemfile:

    gem 'nugrant'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nugrant

## Usage

Create a yaml file named `.vagrantparams` where your
`Vagrantfile` is located. The file must be formatted like
this:

    nuecho:
      ssh_port: 2223
      user:
        git_path: "/home/user/work/git"

The configuration hierarchy you define in your `.vagrantparams`
is imported directly into the config object of the `Vagrantfile`.
So, with the `.vagrantparams` file above, you could have this
`Vagrantfile`.

    require 'nugrant'

    Vagrant::Config.run do |config|
        config.ssh.port config.nuecho.ssh_port

        config.vm.share_folder "git", "/git", config.nuecho.user.git_path
    end

You can also have a `.vagrantparams` under your home directory.
This way, you can set parameters that would be globally available
to all your `Vagrantfile'.

The configuration keys you defined in your home directory
gets overridden by configuration keys found in the `.vagrantparams`
file found under the root folder of your `Vagrantfile`.

## Contributing

There is no direct way to contribute right now.
