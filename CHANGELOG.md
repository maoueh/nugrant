# 2.1.2 (January 12th, 2015)

 * Fixed indifferent access inside arrays. Array elements of type `Hash`
   are now converted to `Bag` instances (recursively). This fix the
   indifferent access of `Bag` elements inside arrays.

   Fixes [issue #27](https://github.com/maoueh/nugrant/issues/27).

# 2.1.1 (December 2nd, 2014)

 * Permit numeric keys in bag. They are converted to symbol
   like others.

   Fixes [issue #26](https://github.com/maoueh/nugrant/issues/26).

 * Removed old code that was switching YAML engine to `syck` when
   it was available.

   Fixes [issue #14](https://github.com/maoueh/nugrant/issues/14) again.

 * Fixed auto export variables on `vagrant provision` feature. The
   initial release is not working correctly.

 * Changed how module shortcut is defined. The shortcut is now defined
   inside the class using it to avoid already defined warnings.

   Fixes [issue #24](https://github.com/maoueh/nugrant/issues/24).

# 2.1.0 (November 1st, 2014)

 * Added possibility to specify the script path where to generate
   the environment commands (export/unset) when using the
   `vagrant user env` command.

* Added possibility to automatically export variables on vagrant provision.
  This can be used by specifying `config.user.auto_export = <format>` in
  your Vagrantfile where <format> can be one of:

   * `false` => No auto export (default value).
   * `:autoenv` => Export to [autoenv](https://github.com/kennethreitz/autoenv) script format.
   * `:script` => Export to a bash script file.
   * `[:autoenv, :script]` => export both format.

  The default generated script path is "./nugrant2env.sh". You can change
  the default script name by specifying the configuration key `config.user.auto_export_script_path`
  in your Vagrantfile:

      config.user.auto_export_script_path = "./script/example.sh"

  Contributed by [@ruifil](https://github.com/ruifil).

# 2.0.2 (July 13th, 2014)

 * Fixed a bug when using some vagrant commands. The code to retrieve
   the Vagrantfile name was not accurate in respect to where it was
   copied. When the env variable `VAGRANT_VAGRANTFILE` is set, it
   then must be wrapped inside an array.

   Fixes [issue #21](https://github.com/maoueh/nugrant/issues/21).

# 2.0.1 (July 10th, 2014)

 * Fixed a bug when using the plugin. A require clause was missing,
   it was working when doing commands but not when using Vagrant
   directly.

   Fixes [issue #20](https://github.com/maoueh/nugrant/issues/20).

# 2.0.0 (July 9th, 2014)

 * Fixed retrieval of current directory for `.vagrantuser`. The directory
   is now that same as the one of the `Vagrantfile`. Rules have been
   copied for Vagrant's one, hence, the behavior should be the same.

 * Fixed bad implementation of config class `::Vagrant.plugin("2", :config)`
   where `merge` was not implemented and was causing errors. Now, all objects
   (i.e. `Config`, `Bag` and `Parameters` implements `merge` and `merge!`
   correctly).

* Added possibility to change array merge strategy. This can
  be used in Vagrant by doing `config.user.array_merge_strategy = <strategy>`
  where valid strategies are:

   * :replace => Replace current values by new ones
   * :extend => Merge current values with new ones
   * :concat => Append new values to current ones

* Better handling in Vagrant of cases where the vagrant user
  file cannot be parsed correctly. This is now reported
  as an error in Vagrant an nicely displayed with the path
  of the offending file and the parser error message.

* Better handling of how global Nugrant options are passed and
  handled. Everything is now located in the `Nugrant::Config`
  object and used by everything that need some configuration
  parameters.

* It is now possible to customize key error handling by passing
  an options hash with key `:key_error` and a `Proc` value.

* Improved command `vagrant user parameters`. The command now checks if
  restricted keys are used and prints a warning when it's the case.

* Added a new command `vagrant user restricted-keys` that prints the keys that
  are restricted, i.e. that cannot be accessed using method access
  syntax.

* Added possibility to specify merge strategy to use when merging
  two arrays together.

### Backward Incompatibilities

* Removed deprecated `--script` argument from `vagrant user env` command.

* Support for Ruby <= 1.9.2 has been dropped. This is not a problem when using
  Nugrant as a Vagrant plugin. Use branch `1.x` if you can't upgrade to
  Ruby >= 1.9.3.

* Support for Vagrant 0.x has been dropped. This means that Nugrant 2.x will not
  load if installed in a Vagrant 0.x environment. Use branch `1.x` if you can't
  upgrade to Vagrant 1.x.

* `Bag` and `Parameters` and Vagrant configuration object `config.user` are now
  [Enumerable](http://ruby-doc.org/core-2.0.0/Enumerable.html).

  This change has implications on the resolving process of the variables
  that are stored in the `Bag` when using the dot syntax `(config.user.email)`
  in your code and `Vagrantfiles`. By using this syntax with version 2.0, some keys
  will collapse with the internal object's methods. In fact, it was already the
  case before but to a much smaller scope because object were not enumerable.

  The number of conflicts should be rather low because the restricted keys
  are not commonly used as parameter name. The list of the restricted keys
  is the following:

      !, !=, !~, <=>, ==, ===, =~, [], __all, __current, __defaults,
      __id__, __send__, __system, __user, _detected_errors, _finalize!,
      all?, any?, chunk, class, clear!, clone, collect, collect_concat,
      compute_all!, compute_bags!, count, cycle, defaults, defaults=,
      define_singleton_method, detect, display, drop, drop_while, dup,
      each, each_cons, each_entry, each_slice, each_with_index,
      each_with_object, empty?, entries, enum_for, eql?, equal?, extend,
      finalize!, find, find_all, find_index, first, flat_map, freeze,
      frozen?, gem, grep, group_by, has?, hash, include?, inject,
      inspect, instance_eval, instance_exec, instance_of?,
      instance_variable_defined?, instance_variable_get,
      instance_variable_set, instance_variables, instance_variables_hash,
      is_a?, kind_of?, lazy, map, max, max_by, member?, merge, merge!,
      method, method_missing, methods, min, min_by, minmax, minmax_by,
      nil?, none?, object_id, one?, partition, private_methods,
      protected_methods, psych_to_yaml, public_method, public_methods,
      public_send, reduce, reject, remove_instance_variable, respond_to?,
      reverse_each, select, send, set_options, singleton_class,
      singleton_methods, slice_before, sort, sort_by, suppress_warnings,
      taint, tainted?, take, take_while, tap, to_a, to_enum, to_hash,
      to_json, to_s, to_set, to_yaml, to_yaml_properties, trust, untaint,
      untrust, untrusted?, validate, zip

* The `Parameter` class has a new API.

* The `Bag` class has a new API.

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
