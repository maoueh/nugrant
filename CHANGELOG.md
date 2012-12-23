# 0.0.12

* Added travis configuration file

# 0.0.11

* Updated README file for installation via rubygems.org

# 0.0.10

* Added a subcommand `parameters` for vagrant command `user`.
* Added a vagrant command `vagrant user subcommand [options]`.

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
