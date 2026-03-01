# Build::Environment

Build::Environment provides a nested hash data structure which can contain lambdas for evaluating environments for generating appropriate build environments.

[![Development Status](https://github.com/ioquatix/build-environment/workflows/Test/badge.svg)](https://github.com/ioquatix/build-environment/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

    gem 'build-environment'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install build-environment

## Usage

A build environment in essence is a key-value storage, but it maintains a linked list so that lookups can be propagated towards the root. This allows a parent to provide, say, defaults, while the child can override these. The envirionment can contain strings, arrays and lambdas, which are evaluated when converting the environment into a hash.

``` ruby
a = Build::Environment.new
a[:cflags] = ["-std=c++11"]

b = Build::Environment.new(a, {})
b[:cflags] = ["-stdlib=libc++"]
b[:rcflags] = lambda{cflags}

b.flatten
```

### Key Logic

When flattening an environment:

  - String values overwrite each other.
  - Array keys are concatenated.
  - Symbols are redirected (i.e. refer to another key-value)

## Releases

There are no documented releases.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
