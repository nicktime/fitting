# Fitting

[![Build Status](https://travis-ci.org/funbox/fitting.svg?branch=master)](https://travis-ci.org/funbox/fitting)

This gem will help you implement your API in strict accordance to the documentation in [API Bluprint](https://apiblueprint.org/) format.
To do this, when you run your RSpec tests on controllers, it automatically searches for the corresponding json-schemas in the documentation and then validates responses with them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fitting'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fitting

## Usage

In your `spec_helper.rb`:

```ruby
  Fitting.configure do |config|
    config.apib_path = '/path/to/doc.apib'
  end
```

## Example output

After running tests you will get statistics in the console:

```
Fully conforming requests:
DELETE  /api/v1/book                 ✔ 200 ✔ 201 ✔ 404
DELETE  /api/v1/book/{id}            ✔ 200 ✔ 201 ✔ 404
GET     /api/v1/book/{id}/seller     ✔ 200 ✔ 201 ✔ 404

Partially conforming requests:
GET     /api/v1/book                 ✖ 200 ✔ 404
POST    /api/v1/book                 ✖ 200 ✔ 201 ✔ 404
GET     /api/v1/book/{id}            ✖ 200 ✔ 404 ✔ 200
PATCH   /api/v1/book/{id}            ✖ 200 ✔ 201 ✔ 404

Non-conforming requests:
GET     /api/v1/seller               ✖ 200 ✖ 201 ✖ 404
GET     /api/v1/buyer                ✖ 200 ✖ 404

API requests with fully implemented responses: 3 (33.33% of 9).
API requests with partially implemented responses: 4 (44.44% of 9).
API requests with no implemented responses: 2 (22.22% of 9).

API responses conforming to the blueprint: 16 (64.00% of 25).
API responses with validation errors or untested: 9 (36.00% of 25).
```

## Matchers

If you want to know why you get crosses instead of checkmarks you can use matchers for RSpec.

```ruby
config.include Fitting::Matchers
```

### match_response

Makes a simple validation against JSON Schema.

```ruby
expect(response).to match_response
```

### strict_match_response

Makes a strict validation against JSON Schema. All properties are condisidered to have `"required": true` and all objects `"additionalProperties": false`.

```ruby
expect(response).to strict_match_response
```

## Config

### apib_path

Path to API Blueprint documentation. There must be an installed [drafter](https://github.com/apiaryio/drafter) to parse it.

### drafter_yaml_path

Path to API Blueprint documentation pre-parsed with `drafter` and saved to a YAML file.

### necessary_fully_implementation_of_responses

Default `true`. It returns `exit 1` if not all responses are implemented according to the documentation. For this to work, `match_response` (see above) should run.

### strict

Default `false`. If `true` then all properties are condisidered to have `"required": true` and all objects `"additionalProperties": false`.

### prefix

Prefix of API requests. Example: `'/api'`.

### white_list

Default: all resources. This is an array of resources that are mandatory for implementation.
This list does not affect the work of the matcher.
This list is only for the report in the console.

```ruby
config.white_list = {
  '/users' =>                ['DELETE', 'POST'],
  '/users/{id}' =>           ['GET', 'PATCH'],
  '/users/{id}/employees' => ['GET'],
  '/sessions' =>             []
}
```

Empty array `[]` means all methods.

### create_report_with_name

File name for the report.

### show_statistics_in_console

Default `true`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/funbox/fitting. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
