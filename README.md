# Build::Environment

Build::Environment provides a nested hash data structure which can contain lambdas for evaluating environments for generating appropriate build environments.

[![Build Status](https://secure.travis-ci.org/ioquatix/build-environment.svg)](http://travis-ci.org/ioquatix/build-environment)
[![Code Climate](https://codeclimate.com/github/ioquatix/build-environment.svg)](https://codeclimate.com/github/ioquatix/build-environment)
[![Coverage Status](https://coveralls.io/repos/ioquatix/build-environment/badge.svg)](https://coveralls.io/r/ioquatix/build-environment)

## Installation

Add this line to your application's Gemfile:

	gem 'build-environment'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install build-environment

## Usage

A build environment in essence is a key-value storage, but it maintains a linked list so that lookups can be propagated towards the root. This allows a parent to provide, say, defaults, while the child can override these. The envirionment can contain strings, arrays and lambdas, which are evaluated when converting the environment into a hash.

```ruby
a = Build::Environment.new
a[:cflags] = ["-std=c++11"]

b = Build::Environment.new(a, {})
b[:cflags] = ["-stdlib=libc++"]
b[:rcflags] = lambda {cflags }

b.flatten
```

### Key Logic

When flattening an environment:

- String values overwrite each other.
- Array keys are concatenated.
- Symbols are redirected (i.e. refer to another key-value)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2012, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
