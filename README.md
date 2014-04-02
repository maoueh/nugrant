# Nugrant

[![Gem Version](https://badge.fury.io/rb/nugrant.png)][gem]
[![Build Status](https://secure.travis-ci.org/maoueh/nugrant.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/maoueh/nugrant.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/maoueh/nugrant.png)][codeclimate]

[gem]: https://rubygems.org/gems/nugrant
[travis]: http://travis-ci.org/maoueh/nugrant
[gemnasium]: https://gemnasium.com/maoueh/nugrant
[codeclimate]: https://codeclimate.com/github/maoueh/nugrant

Nugrant is a library to easily handle parameters that need to be
injected into an application via different sources (system, user,
current, defaults). But foremost, a Vagrant plug-in that will enhance
Vagrantfile to allow user specific configuration values.

Supported platforms:

 * Vagrant 1.x
 * Ruby 1.9.3+

## Overview

Using Nugrant as a plug-in provides an easy and hierarchical system to manage
machine and user specific parameters.

Let's start with an example. You need to distribute among your enterprise a
`Vagrantfile` to start and provision an AWS EC2 instance (or for an open-source project).
The `aws_access_key` and `aws_secret_key` should be configurable depending on the user
running `vagrant up`.

To achieve this, simply create a file named `.vagrantuser` in the project directory with
the following content:

    aws:
      access_key: "123456"
      secret_key: "abcdef"

In your `Vagrantfile`, `Nugrant` will let you access the parameters via the
`config.user` object:

    Vagrant.configure("2") do |config|
      ...

      config.vm.provider :aws do |aws, override|
        aws.access_key_id = config.user.aws.access_key
        aws.secret_access_key = config.user.aws.secret_key

        ...
      end
    end

You then ignore the `.vagrantuser` file in your revision control, so each developer
as a specific one with their own values. People often commit a `.vagrantuser.example`
file in project's repository as an easy startup for the various parameters that
must be filled in, something like:

    aws:
      access_key: "<ACCESS_KEY_HERE>"
      secret_key: "<SECRET_KEY_HERE>"

Moreover, there is a hierarchy of `.vagrantuser` files that you can leverage.
The order is project `.vagrantuser` overrides `$HOME/.vagrantuser` overrides
`$SYSTEM/.vagrantuser` where `$HOME` is the user's home directory and `$SYSTEM`
is the platform dependent folder where system global parameters are set.

We use it in our team to specify the various parameters required for
Vagrant `chef-solo` provisioner by putting the a `.vagrantuser` in our
home directory under a key `chef`. It gets merged with the project's
`.vagrantuser` file (if it exists), so it they can be overridden there.

Please refer to section [Usage](#usage) for all details and explanations
needed to fully use and understand Nugrant.

## Installation

### Vagrant

Vagrant's plug-in system is very well done and Nugrant supports
the following plug-in API versions:

 * V2 => Vagrant 1.x

To install the Nugrant as a Vagrant plug-in, simply type the following
command in a terminal:

    vagrant plugin install nugrant

#### Vagrant 0.x

Vagrant 0.x is not supported anymore. If you still need support for
Vagrant 0.x, please use release line `1.x` (branch [1.x](https://github.com/maoueh/nugrant/tree/1.x)).

### Library

If you would like to use Nugrant as a library, simply reference
it as a dependency of your application. Probably by adding it to
your `Gemfile` or your `.gemspec` file.

    "nugrant", "~> 2.0"

## Usage

Whether used as a library or a Vagrant plug-in, Nugrant has some
common concepts that apply to both usages. The most important
one is the parameters hierarchy.

### Common

Nugrant can read parameters from various locations and will merge
them all together in a single set. Merging is done in a fairly
standard fashion.

Here the precedence rules that apply when merging parameters
from various location. List index indicate the priority of the
entry. Entry with lower number has lower priority (values at this
priority will be overridden by values defined on higher priorities).

 1. Defaults
 2. System
 3. User
 4. Current

In text, this means that current parameters overrides user
parameters, user parameters overrides system parameters and
finally system parameters overrides defaults parameters.

### Vagrant

All examples shown here are for Vagrant 1.1+. They have
been tested with Vagrant 1.4.0. Keep this in mind when
copying examples.

Let start with a small use case. Say the git repository you want
to share with your guest VM is not located under the root folder of
your `Vagrantfile`. That means you will need to specify
an absolute host path to share the folder on the guest VM.

Your `Vagrantfile` would look like this:

    Vagrant.configure("2") do |config|
      config.vm.box = "base"
      config.vm.synced_folder "/home/user/work/git", "/git"
    end

However, what happens when multiple developers
need to share the same `Vagrantfile`? This is the main
use case this plug-in try to address.

When Vagrant starts, it loads all vagrant plug-ins it knows
about. If you installed the plug-in with one of the two
methods we listed above, Vagrant will know about Nugrant
and will load it correctly.

To use the plug-in, first create a YAML file named
`.vagrantuser` in the same folder where your `Vagrantfile` is
located. The file must be a valid YAML file:

    repository:
      project: "/home/user/work/git"

The configuration hierarchy you define in the `.vagrantuser` file
is imported into the `config` object of the `Vagrantfile`
under the key `user`. So, with the `.vagrantuser` file above, you
could have this `Vagrantfile` that abstract absolute paths.

    Vagrant.configure("2") do |config|
      config.vm.box = "base"
      config.vm.synced_folder config.user.repository.project, "/git"
    end

This way, paths can be customized by every developer. They just
have to add a `.vagrantuser` file where user specific configuration
values can be specified. The `.vagrantuser` should be ignored by you
version control system so it is to committed with the project.

Additionally, you can also have a `.vagrantuser` under your user home
directory. This way, you can set parameters that will be
available to all your `Vagrantfile'. The `.vagrantuser` located
within the same folder as the `Vagrantfile` file will overrides
parameters defined in the `.vagrantuser` file defined in the user
home directory.

For example, you have `.vagrantuser` file located at `~/.vagrantuser`
that has the following content:

    ssh_port: 2223
    repository:
      project: "/home/user/work/git"

And another `.vagrantuser` within the same folder as your `Vagrantfile`:

    ssh_port: 3332
    repository:
      personal: "/home/user/personal/git"

Then, the `Vagrantfile` could be defined like this:

    Vagrant.configure("2") do |config|
      config.ssh.port config.user.ssh_port

      config.vm.synced_folder config.user.repository.project, "/git"
      config.vm.synced_folder config.user.repository.personal, "/personal"
    end

That would be equivalent to:

    Vagrant.configure("2") do |config|
      config.ssh.port 3332

      config.vm.synced_folder "/home/user/work/git", "/git"
      config.vm.synced_folder "/home/user/personal/git", "/personal"
    end

As you can see, the parameters defined in the second `.vagrantuser` file
(the current one) overrides settings defined in the `.vagrantuser` found
in the home directory (the user one).

Here the list of locations where Nugrant looks for parameters:

 1. Defaults (via `config.user.defaults` in `Vagrantfile`)
 2. System (`/etc/.vagrantuser` on Unix, `%PROGRAMDATA%/.vagrantuser` or `%ALLUSERSPROFILE%/.vagrantuser` on Windows)
 3. Home (`~/.vagrantuser`)
 4. current (`.vagrantuser` within the same folder as the `Vagrantfile`)

#### Paths

When you want to specify paths on, specially on Windows, it's probably
better to only use forward slash (`/`). The main reason for this is because
Ruby, which will be used at the end by Vagrant is able to deal with forward
slash even on Windows. This is great because with this, you can avoid
values escaping in YAML file. If you need to use backward slash (`\`), don't
forget to properly escape it!

    value: "C:/Users/user/work/git"
    value: "C:\\Users\\user\\work\\git"

Moreover, it is preferable that paths are specified in full
(i.e. no `~` for HOME directory for example). Normally, they
should be handled by `Vagrant` but it may happen that it's not
the case. If your have an error with a specific parameter,
either expand it in your config:

    project: "/home/joe/work/ruby/git"

Of expand it in the `Vagrantfile`:

    config.vm.synced_folder File.expand_path(config.user.repository.project), "/git"

#### Parameters access

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
is not provided by this plug-in but by Vagrant itself.

#### Default values

When using parameters, it is often needed so set default values
for certain parameters so if the user does not define one, the
default value will be picked up.

For example, say you want a parameter that will hold the ssh
port of the vm. This parameter will be accessible via the
parameter `config.user.vm.ssh_port`.

You can use the following snippet directly within your Vagrantfile
to set a default value for this parameter:

    Vagrant.configure("2") do |config|
      config.user.defaults = {
        "vm" => {
          "ssh_port" => "3335"
        }
      }

      config.ssh.port config.user.vm.ssh_port
    end

With this Vagrantfile, the parameter `config.user.vm.ssh_port`
will default to `3335` in cases where it is not defined by the
user.

If the user decides to change it, he just has to set it in his
own `.vagrantuser` and it will override the default value defined
in the Vagrantfile.

#### Commands

In this section, we describe the various vagrant commands defined
by this plug-in that can be used to interact with it.

##### Parameters

This command will print the currently defined parameters at the
given location. All rules are respected when using this command.
It is usefull to see what parameters are available and what are
the current values of those parameters.

Usage:

    > vagrant user parameters
    ---
    config:
      user:
        chef:
          cookbooks_path: /Users/Chef/kitchen/cookbooks
          nodes_path: /Users/Chef/kitchen/nodes
          roles_path: /Users/Chef/kitchen/roles

Add flag `-h` (or `--help`) for description of the command and a
list of available options.

##### Env

Sometimes, you would like to have acces to the different values
stored in your `.vagrantuser` from environment variables. This
command is meant is exactly for this.

By using one of the three methods below, you will be able to export
(but also unset) environment variables from your current
parameters as seen by Nugrant.

You can see the commands that will be executed by simply
calling the method:

    vagrant user env

The name of the environment will be upper cased and full path of
the key, without the `config.user` prefix, separated
with `_`. For example, the key accessible using
`config.user.db.user` and with value `root` would generate the
export command:

    export DB_USER=root

And the unset command:

    unset DB_USER

The value are escaped so it is possible to define value containing
spaces for example.

A last note about generate commands is that pre-existing environment
variable are not taking in consideration by this command. So if
an environment variable with name `DB_USER` already exist, it
would be overwritten by an export command.

Add flag `-h` (or `--help`) for description of the command and a
list of available options.

###### Method #1

If you plan to use frequently this feature, our best suggestion
is to create a little bash script that will simply delegates
to the real command. By having a bash script that calls the
command, you will be able to easily export environment variables
by sourcing the script.

Create a file named `nugrant2env` somewhere accessible from
the `$PATH` variable with the following content:

    #!/bin/env sh

    $(vagrant user env "$@")

This script will simply delegates to the `vagrant user env`
command and pass all arguments it receives to it. The
magic happens because the command `vagrant user env` outputs
the various export commands to the standard output.

By sourcing the simple delegating bash script, the parameters
seen by Nugrant will be available in your environment:

    . nugrant2env

By default, export commands are generated. But you can pass
some options to the `nugrant2env` script, For example, to
generate the unset ones, add `--unset` (or simply `-u`).

    . nugrant2env --unset

For a list of options, see the help of the command delegated
to:

    vagrant user env -h

###### Method #2

Use the command to generate a base script in the current
directory that you will then source:

    vagrant user env --format script

This will generate a script called `nugrant2env.sh` into the
current directory. You then simply source this script:

    . nugrant2env.sh

Using `vagrant user env -u --format script` will instead generate the bash
script that will unset the environment variables. Don't forget
to source it to unset variables.

###### Method #3

Use the command to generate an [autoenv](https://github.com/kennethreitz/autoenv)
file in the current directory. By using the [autoenv] project, anytime you
will enter the project directory via the `cd` command, variables
exported found in the `.env` file generated will be exported to
your environment.

    vagrant user env --format autoenv

This will generate a file called `.env` in the
current directory. You then simply change to the directory
where the `.env` file was generated to made exported variables
available in your environment.

    cd ..
    cd <project_dir>

Using `vagrant user env -u --format autoenv` will instead generate
the autoenv file that will unset the environment variables.

### Library

Using Nugrant as a library to handle parameters from various
location is really easy. Two main classes need to be handled.

First, you need to create a `Nugrant::Config` object. This
configuration holds the values that needs to be customized
by your own application. This includes the different parameters paths
and the format of the parameters file.

## Contributing

You can contribute by filling issues when something goes
wrong or was not what you expected. I will do my best
to fix the issue either in the code or in the documentation,
where applicable.

You can also send pull requests for any feature or improvement
you think should be included in this plug-in. I will evaluate
each of them and merge them as fast as possible.
