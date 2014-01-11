# Perpetuity::Memory

This is the in-memory adapter for Perpetuity.

## Installation

Add this line to your application's Gemfile:

    gem 'perpetuity-memory'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install perpetuity-memory

## Usage

Put this at the top of your application (or in a Rails initializer):

```ruby
require 'perpetuity/memory' # Unnecessary if using Rails
Perpetuity.data_source :memory
```

For information on using Perpetuity to persist your Ruby objects, see the [main Perpetuity repo](https://github.com/jgaskins/perpetuity).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
