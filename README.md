# Nugrant

Vagrant plugin that brings user specific configuration
options. It will enable a `.vagrantuser` at different
location that will get imported into the main vagrant
config.

For example, let say the git repository you want to
expose is not located under the root folder of
your `Vagrantfile`. That means you will need to specify
an absolute host path to share the folder on the guest vm.

Your `Vagrantfile` would look like this:

    Vagrant::Config.run do |config|
        config.vm.share_folder "git", "/git", "/home/user/work/git"
    end

However, what happens when multiple developers
need to share the same `Vagrantfile`? This is the main
use case this plugin address.

## Installation

First, you need to have Vagrant installed for this gem
to work correctly.

There is two different way to install the gem. You can
install it via Vagrant or via the system gem containers.

When you install from Vagrant, the main benefit is that
it's decoupled from your other system gems. There is less
chance for this gem's dependencies, even if they are minimal,
to clash with gems already installed on your system. This is the
recommended installation method. To install, simply run:

    > vagrant gem install nugrant-x.x.x.gem

If you prefer to install the gem in a system wide matters,
please use this command instead:

    > gem install nugrant-x.x.x.gem

Where x.x.x is the version of the gem you wish to install.

## Usage

When Vagrant starts, via any of the `vagrant` commands,
it loads all vagrant plugins it founds under the `GEM_PATH`
variable. If you installed the plugin with one of the two
methods we listed above, you DO NOT need to setup this
environment variable since.

To use the plugin, first create a yaml file named
`.vagrantuser` where your `Vagrantfile` is located. The file
must be a valid yaml file:

    vm_port: 2223
    repository:
      project: "/home/user/work/git"

The configuration hierarchy you define in the `.vagrantuser` file
gets imported into the `config` object of the `Vagrantfile`
under the key `user`. So, with the `.vagrantuser` file above, you
could have this `Vagrantfile` that abstract absolute paths.

    Vagrant::Config.run do |config|
        config.ssh.port config.user.vm_port

        config.vm.share_folder "git", "/git", config.user.repository.project
    end

This way, paths can be customized by every developer. They just
have to add a `.vagrantuser` file where user specific configuration
values can be specified. The `.vagrantuser` should be ignored by you
version control system so it is to committed with the project.

Additionally, you can also have a `.vagrantuser` under your user home
directory. This way, you can set parameters that would be userly
available to all your `Vagrantfile'. The project `.vagrantuser`
file will overrides parameters defined in the `.vagrantuser` file
defined in the user home directory

For example, you have `.vagrantuser` file located at `~/.vagrantuser`
that has the following content:

    vm_port: 2223
    repository:
      project: "/home/user/work/git"

And another `.vagrantuser` at the root of your `Vagrantfile`:

    vm_port: 3332
    repository:
      personal: "/home/user/personal/git"

Then, the `Vagrantfile` could be defined like this:

    Vagrant::Config.run do |config|
        config.ssh.port config.user.vm_port

        config.vm.share_folder "git", "/git", config.user.repository.project
        config.vm.share_folder "personal", "/personal", config.user.repository.personal
    end

That would be equivalent to:

    Vagrant::Config.run do |config|
        config.ssh.port 3332

        config.vm.share_folder "git", "/git", "/home/user/work/git"
        config.vm.share_folder "personal", "/personal", "/home/user/personal/git"
    end

As you can see, the parameters defined in the second `.vagrantuser` file
(the project one) overrides settings defined in the `.vagrantuser` found
in the home directory (the user one).

### Parameters access

Parameters in the `Vagrantfile` can be retrieved via method call
of array access.

    config.user['repository']['project'] # Array access
    config.user.repository.project       # Method access

You can even mix the two if you want, but we do not recommend
it since its always better to be consistent:

    config.user['repository'].project # Mixed access
    config.user.repository['project'] # Mixed access

Only the root key, i.e. `config.user`, cannot be access with
both syntax, only the method syntax can be used since this
is not provided by this plugin but by Vagrant itself.

## Contributing

There is no direct way to contribute right now.
