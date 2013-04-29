# Changelog

## master (unreleased)

### New features

* Relax semicolon rule for one line methods, classes and modules

### Bugs fixed

* [#101](https://github.com/bbatsov/rubocop/issues/101) SpaceAroundEqualsInParameterDefault doesn't work properly with empty string

## 0.6.1 (04/28/2013)

### New features

* Split AsciiIdentifiersAndComments cop in two separate cops

### Bugs fixed

* [#90](https://github.com/bbatsov/rubocop/issues/90) Two cops crash when scanning code using super
* [#93](https://github.com/bbatsov/rubocop/issues/93) Issue with whitespace?': undefined method
* [#97](https://github.com/bbatsov/rubocop/issues/97) Build fails
* [#100](https://github.com/bbatsov/rubocop/issues/100) OpMethod cop doesn't work if method arg is not in braces
* SymbolSnakeCase now tracks Ruby 1.9 hash labels as well as regular symbols

### Misc

* [#88](https://github.com/bbatsov/rubocop/issues/88) Abort gracefully when interrupted with Ctrl-C
* No longer crashes on bugs within cops. Now problematic checks are skipped and a message is displayed.
* Replaced Term::ANSIColor with Rainbow.
* Add an option to disable colors in the output.
* Cop names are now displayed alongside messages when `-d/--debug` is passed.

## 0.6.0 (04/23/2013)

### New features

* New cop `ReduceArguments` tracks argument names in reduce calls
* New cop `MethodLength` tracks number of LOC (lines of code) in methods
* New cop `RescueModifier` tracks uses of `rescue` in modifier form.
* New cop `PercentLiterals` tracks uses of `%q`, `%Q`, `%s` and `%x`.
* New cop `BraceAfterPercent` tracks uses of % literals with
  delimiters other than ().
* Support for disabling cops locally in a file with rubocop:disable comments.
* New cop `EnsureReturn` tracks usages of `return` in `ensure` blocks.
* New cop `HandleExceptions` tracks suppressed exceptions.
* New cop `AsciiIdentifiersAndComments` tracks uses of non-ascii
  characters in identifiers and comments.
* New cop `RescueException` tracks uses of rescuing the `Exception` class.
* New cop `ArrayLiteral` tracks uses of Array.new.
* New cop `HashLiteral` tracks uses of Hash.new.
* New cop `OpMethod` tracks the argument name in operator methods.
* New cop `PercentR` tracks uses of %r literals with zero or one slash in the regexp.
* New cop `FavorPercentR` tracks uses of // literals with more than one slash in the regexp.

### Bugs fixed

* [#62](https://github.com/bbatsov/rubocop/issues/62) - Config files in ancestor directories are ignored if another exists in home directory
* [#65](https://github.com/bbatsov/rubocop/issues/65) - Suggests to convert symbols :==, :<=> and the like to snake_case
* [#66](https://github.com/bbatsov/rubocop/issues/66) - Does not crash on unreadable or unparseable files
* [#70](https://github.com/bbatsov/rubocop/issues/70) - Support `alias` with bareword arguments
* [#64](https://github.com/bbatsov/rubocop/issues/64) - Performance issue with Bundler
* [#75](https://github.com/bbatsov/rubocop/issues/75) - Make it clear that some global variables require the use of the English library
* [#79](https://github.com/bbatsov/rubocop/issues/79) - Ternary operator missing whitespace detection

### Misc

* Dropped Jeweler for gem release management since it's no longer
  actively maintained.
* Handle pluralization properly in the final summary.

## 0.5.0 (04/17/2013)

### New features

* New cop `FavorSprintf` that checks for usages of `String#%`
* New cop `Semicolon` that checks for usages of `;` as expression separator
* New cop `VariableInterpolation` that checks for variable interpolation in double quoted strings
* New cop `Alias` that checks for uses of the keyword `alias`
* Automatically detect extensionless Ruby files with shebangs when search for Ruby source files in a directory

### Bugs fixed

* [#59](https://github.com/bbatsov/rubocop/issues/59) - Interpolated variables not enclosed in braces are not noticed
* [#42](https://github.com/bbatsov/rubocop/issues/42) - Received malformed format string ArgumentError from rubocop
