# Extensions

It's possible to extend RuboCop with custom cops and formatters.

## Loading Extensions

Besides the `--require` command line option you can also specify ruby
files that should be loaded with the optional `require` directive in the
`.rubocop.yml` file:

```yaml
require:
 - ../my/custom/file.rb
 - rubocop-extension
```

!!! Note

    The paths are directly passed to `Kernel.require`. If your
    extension file is not in `$LOAD_PATH`, you need to specify the path as
    relative path prefixed with `./` explicitly or absolute path. Paths
    starting with a `.` are resolved relative to `.rubocop.yml`.

## Custom Cops

You can configure the custom cops in your `.rubocop.yml` just like any
other cop.

### Writing your own Cops

If you'd like to create an extension gem, you can use [rubocop-extension-generator](https://github.com/rubocop-hq/rubocop-extension-generator).

See [development](development.md) to learn how to implement a cop.

### Known Custom Cops

* [rubocop-performance](https://github.com/rubocop-hq/rubocop-performance) -
  Performance optimization analysis
* [rubocop-rails](https://github.com/rubocop-hq/rubocop-rails) -
  Rails-specific analysis
* [rubocop-rspec](https://github.com/rubocop-hq/rubocop-rspec) -
  RSpec-specific analysis
* [rubocop-thread_safety](https://github.com/covermymeds/rubocop-thread_safety) -
  Thread-safety analysis
* [rubocop-require_tools](https://github.com/milch/rubocop-require_tools) -
  Dynamic analysis for missing require statements
* [rubocop-i18n](https://github.com/puppetlabs/rubocop-i18n) -
  i18n wrapper function analysis (gettext and rails-i18n)
* [rubocop-sequel](https://github.com/rubocop-hq/rubocop-sequel) -
  Code style checking for Sequel gem
* [cookstyle](https://github.com/chef/cookstyle) -
  Custom cops and config defaults for Chef Infra Cookbooks
* [rubocop-rake](https://github.com/rubocop-hq/rubocop-rake) -
  Rake-specific analysis

Any extensions missing? Send us a Pull Request!

## Custom Formatters

You can customize RuboCop's output format with custom formatters.

### Creating a Custom Formatter

To implement a custom formatter, you need to subclass
`RuboCop::Formatter::BaseFormatter` and override some methods,
or implement all formatter API methods by duck typing.

Please see the documents below for more formatter API details.

* [RuboCop::Formatter::BaseFormatter](https://www.rubydoc.info/gems/rubocop/RuboCop/Formatter/BaseFormatter)
* [RuboCop::Cop::Offense](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Offense)
* [Parser::Source::Range](https://www.rubydoc.info/gems/parser/Parser/Source/Range)

### Using a Custom Formatter from the Command Line

You can tell RuboCop to use your custom formatter with a combination of
`--format` and `--require` option.
For example, when you have defined `MyCustomFormatter` in
`./path/to/my_custom_formatter.rb`, you would type this command:

```sh
$ rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
```
