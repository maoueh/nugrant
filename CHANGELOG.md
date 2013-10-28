# 1.2.1 (unreleased)

* Keys associated to a null value are considered as being missing
  by the merging process. It is still possible to define a null
  parameter, but it will be overrided by any parameter and will not
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
  from working as expected. [GH-4](https://github.com/maoueh/nugrant/issues/4)
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
* Introduced restricted keys (For now, restricted keys are [`defaults`])
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
