# 2.0.0 (In progress)

### Backward Incompatibilities

* `Bag` and `Parameters` are now [Enumerable](http://ruby-doc.org/core-2.0.0/Enumerable.html).

  This change has implications on the resolving process of the variables
  that are stored in the `Bag` when using the dot syntax `(user.email.value)`
  in your code. By using this method with the new model, more keys will
  collapse with method from the `Bag` class itself but also newly added method
  via the `Enumerable` module.

  The list of the restricted keys are the ones defined on the
  [Enumerable] module plus somes directly defined on the nugrant
  [Bag]:

      # From Enumerable
      all?, any?, chunk, collect, collect_concat, count, cycle,
      detect, drop, drop_while, each_cons, each_entry, each_slice,
      each_with_index, each_with_object, entries, find, find_all,
      find_index, first, flat_map, grep, group_by, include?,
      inject, lazy, map, max, max_by, member?, min, min_by,
      minmax, minmax_by, none?, one?, partition, reduce, reject,
      reverse_each, select, slice_before, sort, sort_by, take,
      take_while, to_a, zip

      # From Bag
      initialize, method_missing, [], empty?, merge!, update!, to_hash,
      __convert_key.

* The `Bag` class has a new API.

# 1.4.3 (In progess)

# 1.4.2 (January 11th, 2014)

* Fixed Vagrant `user` config class to make the `has?` method
  available to people using Vagrant. This considered has a bug
  fix because using `has?` was not working anyway before.

# 1.4.1 (December 15th, 2013)

* Fixed a superfluous warning message when using ruby >= 2.0.0 which is now the
  default when installing Vagrant >= 1.4.0 (at least on Windows).

# 1.4.0 (November 28th, 2013)

* Adding support to export to an [autoenv](https://github.com/kennethreitz/autoenv)
  file. See [GH-13](https://github.com/maoueh/nugrant/issues/13).

* Deprecated usage of `-s, --script` option for command
  `vagrant user env`. This was replaced by the more generic
  and extensible `-f, --format FORMAT` option. The
  `-s, --script` option will be removed in 2.0.

# 1.3.0 (November 19th, 2013)

* Now using [minitest](https://github.com/seattlerb/minitest) as our
  testing library.

* Added a new command that can be used either standalone or via
  a small bash script to easily export environment variables
  from your currently set parameters. See
  [GH-13](https://github.com/maoueh/nugrant/issues/13).

* Keys associated to a null value are considered as being missing
  by the merge process. It is still possible to define a null
  parameter, but it will be overridden by any parameter and will not
  override any. See [GH-12](https://github.com/maoueh/nugrant/issues/12).

* Fixed output of command `vagrant user parameters`, the keys were
  serialized as symbol instead of string.

# 1.2.0 (October 24th, 2013)

* Now showing better error message to the end-user when a parameter
  cannot be found. The message displays which key could not be found.
  Moreover, we show the context within the Vagrantfile where we think
  the error occurred:

  ```
  Nugrant: Parameter 'param' was not found, is it defined in
  your .vagrantuser file? Here where we think the error
  could be in your Vagrantfile:

   1:     Vagrant.configure("2") do |config|
   2:>>     puts config.user.param
   3:     end
  ```

  See [GH-8] (https://github.com/maoueh/nugrant/issues/8).

* Ensured that keys used within a `Bag` are always symbol. This make
  sure that it is possible to retrieve a value with any access method.
  See [GH-9](https://github.com/maoueh/nugrant/issues/9).

* Now using [multi_json](https://rubygems.org/gems/multi_json)
  for JSON handling.

# 1.1.0 (May 17th, 2013)

* Rewrite completely classes `Parameters` and `Bag`.
* Reduced chances to have a parameter name collapsing with an
  implementation method.

* Removed dependency on `deep_merge`. We do now perform
  our own merge.

* Added possibility to iterate through keys by using
  `.each`:

  ```
  config.user.local.each do |name, value|
    puts "Key #{name}: #{value}"
  end
  ```

### Backward Incompatibilities

* `Parameters` is not extending the `Bag` class anymore.

* `Parameters` and `Bag` attributes and methods are now almost
  all prefixed with __ to reduce clashes to a minimum when
  accessing parameters with method-like syntax
  (i.e. `parameters.git.master` instead of `parameters['git']['master']`)

# 1.0.1 (April 9th, 2013)

* Fixed a crash when `user` config value is `nil` preventing `vagrant user parameters`
  from working as expected. See [GH-4](https://github.com/maoueh/nugrant/issues/4).

* Fixed a bug preventing the version from being printed when doing `vagrant user -v`.

# 1.0.0 (March 21th, 2013)

* For now on, this gem will follow semantic versioning.
* Refactored how Vagrant plugin is architectured.
* Now supporting Vagrant 1.1.x (Plugin version "2").

# 0.0.14

* Renamed `ParameterBag` to `Bag`

* Cleanup `Bag` api
 * Renamed method `has_param?` to `has_key?` in `Bag`
 * Removed method `get_params` from `Bag`

# 0.0.13

* Cleanup `Parameters` and `ParameterBag` interface
 * The method `defaults` has been removed from the bag
 * Setting defaults on `Parameters` now recompute the final bag

* Improved `vagrant user parameters` command
 * Now using the exact config as seen by Vagrant, this includes defaults parameters
 * An option has been added to only see defaults parameters

# 0.0.12

* Added travis configuration file

* Added travis build status icon to readme

* Fixed a bug when `.vagrantuser` file is empty or not a hash type

* Improved parameters command
 * The parameters command is now a proper subcommand
 * An option has been added to see system parameters
 * An option has been added to see user parameters
 * An option has been added to see project parameters

# 0.0.11

* Updated README file for installation via rubygems.org

# 0.0.10

* Added a subcommand `parameters` for vagrant command `user`

* Added a vagrant command `vagrant user subcommand [options]`

# 0.0.9

* Fixed a bug with the new default values implementation

# 0.0.8

* Introduced possibility to set default values

* Introduced restricted keys (For now, restricted keys are [`defaults`]).

* Fixed a bug with system-wide parameters

# 0.0.7

* YAML is back as the default file format for parameters

# 0.0.6

* Fixed a bug on ruby 1.8.7 which doesn't have yaml included in its load path by default

# 0.0.5

* Introduced system-wide parameters file

# 0.0.4

* JSON is now the default file format for parameters (due to problem with YAML)

* It is now possible to store parameters in the JSON format
