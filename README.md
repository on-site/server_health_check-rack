# server_health_check-rack


This gem provides a rack middleware that will look for a `/health` request and
utilize the [server_health_check gem](https://github.com/on-site/server_health_check)
to determine if the server is healthy and respond with a proper HTTP status code
and JSON response. Individual checks can be done by adding them to the URL, like
`/health/specific_check`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "server_health_check-rack"
```

And then execute:

    $ bundle

Then configure your checks with the gem using the built in `server_health_check`
checks, or your own custom checks:

```ruby
ServerHealthCheckRack::Checks.check_active_record!
ServerHealthCheckRack::Checks.check_redis!(host: "someredis.host", port: 1234)
ServerHealthCheckRack::Checks.check_aws_s3!("aws-bucket-to-check")
ServerHealthCheckRack::Checks.check_aws_creds!
ServerHealthCheckRack::Checks.check "custom_check" do
  # Do some work here, then return true if it succeeded or false if not
  # (exceptions will be caught by the server_health_check gem and the message
  # will be reported as the status).
  true
end
```

And indicate the path to listen against (if you don't want the default of
`/health`):

```ruby
ServerHealthCheckRack::Config.path = "/check/health"
```

You can also indicate a custom logger for the [`server_health_check`](https://github.com/on-site/server_health_check)
gem to utilize (it defaults to not overriding the logger):

```ruby
ServerHealthCheckRack::Config.logger = MyCustomLogger.new
```

## Usage

You can now use your health checks in some automated service to monitor your app
with your custom checks.

You may use the endpoint for all checks at `/health`, which might result in
something like the following, though without the formatting:

```json
{
    "status": {
        "active_record": "OK",
        "redis": "OK",
        "aws_s3": "Failed",
        "aws_creds": "OK",
        "custom_check": "OK"
    }
}
```

If you want to just check a single check, you can just use that in the url like
`/health/custom_check`:

```json
{
    "status": {
        "custom_check": "OK"
    }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/on-site/server_health_check-rack. This project is intended
to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

