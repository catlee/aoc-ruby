# AoC

The AoC gem provides some helpers to assist in writing [advent of code](https://adventofcode.org) solutions in Ruby.

## Usage

Normally no extra configuration is needed to get `aoc` working.

```ruby
# projects/aoc/2021/day1.rb
require "aoc"
require "minitest/autorun"

class Day1 < Minitest::Test
  def test_part1
    puts "Day 1 input is: #{DAY1_text}"
  end
end
```

The input data for December 1, 2021 will be downloaded, cached, and returned to the ruby code above as a string in the `DAY1_text` constant.

Authentication is handled by looking at your browser's cookie store. This can be overwritten, see the [Authentication](#Authentication) section.

### Magic constants for fetching input data

You can use constants such as `DAY1_text` to fetch the input for your problem.

Supported suffixes are:
| suffix | description |
| ---    | --- |
| _raw  | returns the raw input data |
| _text | returns the data as a string, with trailing whitespace trimmed |
| _lines | returns the data as an Array of lines, with trailing whitespace on each line trimmed |
| _number | returns the input data as a single integer |
| _numbers | returns the input data as n Array of integers |

The input data is cached in `inputs/<year>/<day>.txt` relative to your current working directory.

### Guessing the year

This gem will look at the `AOC_YEAR` environment variable to determine which year to use when downloading the input data.
Alternatively, it will look in `.aoc-year` in your local working directory.
Finally, it will look at the current working directory and see if a year-like number appears in the full directory name. Year-like numbers are numbers from 2015 to the current year.

This means that you can have a directory structure that contains a single year's problems, and this gem should use that as the year to use when fetching input data.

### Firefox cookie support

This gem will attempt to read the authentication cookie from Firefox's cookie
store, and use that when fetching input data.

(currently only works with Firefox on MacOS. I'd love to add Windows, Linux, and Chrome support)

### Authentication

You can override the cookie behaviour above and specify an authentication token by setting AOC_SESSION in your environment.

Alternatively, you can save the session cookie value into `.aoc-session`, in your local working directory or in `~/.config/.aoc-session`.

Both of these methods will be tried, in this order, before checking browser cookies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aoc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aoc

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `aoc.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/catlee/aoc-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Aoc project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/catlee/aoc-ruby/blob/main/CODE_OF_CONDUCT.md).
