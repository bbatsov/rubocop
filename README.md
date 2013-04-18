[![Gem Version](https://badge.fury.io/rb/rubocop.png)](http://badge.fury.io/rb/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.png?branch=master)](https://travis-ci.org/bbatsov/rubocop)

# RuboCop

**RuboCop** is a Ruby code style checker based on the
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

## Installation

**RuboCop**'s installation is pretty standard:

```bash
$ gem install rubocop
```

## Basic Usage

Running `rubocop` with no arguments will check all Ruby source files
in the current folder:

```bash
$ rubocop
```

Alternatively you can `rubocop` a list of files and folders to check:

```bash
$ rubocop app spec lib/something.rb
```

For more details check the available command-line options:

```bash
$ rubocop -h
```

Command flag       | Description
-------------------|------------------------------------------------------------
`-v/--version`     | Displays the current version and exits
`-d/--debug`       | Displays some extra debug output
`-e/--emacs`       | Output the results in Emacs format
`-c/--config`      | Run with specified config file
`-s/--silent`      | Suppress the final summary

## Configuration

The behavior of RuboCop can be controlled via the
[.rubocop.yml](https://github.com/bbatsov/rubocop/blob/master/.rubocop.yml)
configuration file. The file can be placed either in your home folder
or in some project folder.

RuboCop will start looking for the configuration file in the directory
it was started in and continue its way up to the home folder.

The file has the following format:

```yml
Encoding:
  Enabled: true

LineLength:
  Enabled: true
  Max: 79
```

It allows to enable/disable certain cops (checks) and to alter their
behavior if they accept any parameters.

## Compatibility

Unfortunately every major Ruby implementation has its own code
analysis tooling, which makes the development of a portable code
analyzer a daunting task.

RuboCop currently supports MRI 1.9 and MRI 2.0. Support for JRuby and
Rubinius is not planned at this point.

## Editor integration

### Emacs

[rubocop.el](https://github.com/bbatsov/rubocop-emacs) is a simple
Emacs interface for RuboCop. It allows you to run RuboCop inside Emacs
and quickly jump between problems in your code.

[flycheck](https://github.com/lunaryorn/flycheck) > 0.9 also supports
RuboCop and uses it by default when available.

### Other Editors

Here's one great opportunity to contribute to RuboCop - implement
RuboCop integration for your favorite editor.

## Contributors

Here's a [list](https://github.com/bbatsov/rubocop/contributors) of
all the people who have contributed to the development of RuboCop.

I'm extremely grateful to each and every one of them!

I'd like to single out [Jonas Arvidsson](https://github.com/jonas054)
for his many excellent code contributions as well as valuable feedback
and ideas!

If you'd like to contribute to RuboCop, please take the time to go
through our short
[contribution guidelines](CONTRIBUTING.md).

Converting more of the Ruby Style Guide into RuboCop cops is our top
priority right now. Writing a new cop is a great way to dive into RuboCop!

Of course, bug reports and suggestions for improvements are always
welcome. GitHub pull requests are even better! :-)

## Changelog

RuboCop's changelog is available [here](CHANGELOG.md).

## Copyright

Copyright (c) 2012-2013 Bozhidar Batsov. See [LICENSE.txt](LICENSE.txt) for
further details.
