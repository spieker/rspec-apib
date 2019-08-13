# Rspec::Apib

This is meant to be a drop-in solution for generating an API documentation from
existing RSpec request specs. The result is not always perfect, but hopefully
gives your developers and/or customers an idea of how your API works.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-apib'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-apib

## Usage

```ruby
# rails_helper.rb
# ...
require 'rspec/apib'

# Configuration
RSpec::Apib.configure do |config|
  # Define pre documentation files
  config.pre_docs = Dir[Rails.root.join('docs/pre_*.md')]

  # Define post documentation files
  config.post_docs = Dir[Rails.root.join('docs/post_*.md')]

  # Define output file
  config.dest_file = Rails.root.join('apiary.apib')

  # Example types to record
  config.record_types = [:request]
end
# ...
RSpec::Apib.start
```

### Writing tests

By default, request specs get recorded and written to a `.apib` file afterwards.
Rspec-apib is trying to make sense of the test run and generates a meaningful
documentation out of it.

- **Disable single examples:** Add `apib: false` to the examples meta data

  ```ruby
  it 'does something', apib: false do
    # ...
  end
  ```

- **Custom example description:** Add an _apib_ comment above the example
  You can add a description for the request, response or both.

  Description only for the request

  ````ruby
  # Not contained in the description
  #
  # --- apib_request
  # Some awesome description of the request
  #
  # ```json
  # {}
  # ```
  # ---
  #
  # Not contained in the description
  #
  it 'has a custom description' do
    # ...
  end
  ````

  Description only for the response

  ````ruby
  # Not contained in the description
  # -- apid_response
  # Some awesome description of the response
  #
  # ```json
  # {}
  # ```
  # ---
  #
  # Not contained in the description
  #
  it 'has a custom description' do
    # ...
  end
  ````

  Description for both request and response

  ````ruby
  # Not contained in the description
  #
  # --- apib_request
  # Some awesome description of the request
  #
  # -- apid_response
  # Some awesome description of the response
  #
  # ```json
  # {}
  # ```
  # ---
  #
  # Not contained in the description
  #
  it 'has a custom description' do
    # ...
  end
  ````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

To do continuous testing during development `guard` can be used. In order to
test against multiple versions of Rails, the environment variable
`RAILS_VERSION` can be used to choose a different dependency pattern then the
default one specified in the _.gemspec_ file.

```
RAILS_VERSION='~> 4.0' bundle install; bundle exec rspec
RAILS_VERSION='~> 5.0' bundle install; bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spieker/rspec-apib. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
