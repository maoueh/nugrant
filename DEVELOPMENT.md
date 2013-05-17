# Nugrant [![Build Status](https://travis-ci.org/maoueh/nugrant.png)](https://travis-ci.org/maoueh/nugrant)

Since at first I wanted to have support for plugin api V1 and V2 in the same
codebase without having to switch between branches, development is a bit
more complicated than usual.

As many other ruby projects, Nugrant use `bundler` to manage its dependencies.
However, as not many ruby projects, Nugrant supports two incompatible version
of Vagrant.

For this reason, the `Gemfile` used by `bundler` is conditional to an
environment variable. The environment used is `VAGRANT_PLUGIN_VERSION`.
When it is set, it can take the value `v1` or `v2` which is the plugin
version you want to test. By default, if the environment variable is
not set, `v2` is the default.

## Develop Nugrant for Vagrant api v1

To do this, you will need to set and environment variable
`VAGRANT_PLUGIN_VERSION` to `v1` prior to calling bundle
install, like this:

    VAGRANT_PLUGIN_VERSION="v1" bundle install

This will instruct `bundler` to setup Vagrant `1.0.z`, which
at the time of talking, is `1.0.7`.

## Develop Nugrant for Vagrant api v2

You can simply install the dependencies normally by doing:

    bundle install


