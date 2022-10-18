# Telly

#### Dynamic linting for your rails apps.

Telly runs a simple HTTP server which mounts onto your Rails app in development, and provides a simple
interface for Rubocop to fetch runtime information about your app. Check **Features** below to see
what it can _currently_ do.

### Features

- Linting for routes
  - Check that a specified controller action exists
- Linting `belongs_to`, `has_many` and `has_one` relationships in models
  - Check that specified primary and foreign keys exist in a relationship
  - Check that foreign key and primary key types match
  - Check that the related model still has a table in the DB

##### Coming soon:

- Check that non-nullable columns in a DB table have corresponding not-null constraints at the
  application level
- Check that ActiveRecord uniqueness validations have a corresponding index in the DB (performance)

## Usage

Install the gem and then that's it! Configure your `.rubocop.yml` to enable/disable whichever rules
you like

## Installation
Add this line to your application's Gemfile:

```ruby
gem "telly", group: :development
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install telly
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
