# ChipRails

This is the unofficial Ruby gem for Chip In Asia payment gateway. Specifically designed to work with Ruby on Rails

## Installation

Install the gem and add to the application's Gemfile by executing:

    bundle add chip_rails

If bundler is not being used to manage dependencies, install the gem by executing:

    gem install chip_rails

## Usage

Add this file to your rails project at config/initializer/chip_rails.rb:

    ChipRails.configure do |config|
      config.api_key = ENV['CHIP_API_KEY']
      config.brand_id = ENV['CHIP_BRAND_ID']
      config.webhook_key = ENV['CHIP_WEBHOOK_KEY']
    end


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/chip_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/chip_rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ChipRails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/chip_rails/blob/main/CODE_OF_CONDUCT.md).
