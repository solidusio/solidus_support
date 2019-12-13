# SolidusSupport

This gem holds some common functionality for Solidus Extensions.

It has some utilities to make it easier to support multiple versions of Solidus.

## Usage

### `SolidusSupport::Migration`

Rails >= 5 introduced the concept of specifying what rails version your migration was written for, like `ActiveRecord::Migration[5.0]`.
Not specifying a version is deprecated in Rails 5.0 and removed in rails 5.1.
This wasn't backported to Rails 4.2, but Rails 4.2 _is_ Rails 4.2. So we provide this helper.

``` ruby
# On Rails 4.2
SolidusSupport::Migration[4.2] # returns `ActiveRecord::Migration`
SolidusSupport::Migration[5.0] # errors

# On Rails 5.0
SolidusSupport::Migration[4.2] # same as `ActiveRecord::Migration[4.2]`
SolidusSupport::Migration[5.0] # same as `ActiveRecord::Migration[5.0]`
```

There's no reason to use `SolidusSupport::Migration[5.0]` over `ActiveRecord::Migration[5.0]`, but it is provided.

### Engine Extensions

This extension provides a module that extends `Rails::Engine` functionalities
to support loading correctly the decorators class created into an extension
both for development and production enviroments.

To use it just include the provided module in the Engine as follow:

```ruby
module SolidusExtensionName
  class Engine < Rails::Engine
    engine_name 'solidus_extension_name'

    include SolidusSupport::EngineExtensions::Decorators
    # ...
  end
end
```

To make it work, be sure to remove the previous implementation from the
Engine, that should be something like:

```ruby
def self.activate
  Dir.glob(File.join(root, "app/**/*_decorator*.rb")) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end

config.to_prepare(&method(:activate).to_proc)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solidusio/solidus_support.
