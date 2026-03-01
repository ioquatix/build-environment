# Getting Started

This guide explains how to get started with `build-environment`, a nested key-value data structure for organising build configurations.

## Installation

Add the gem to your project's `Gemfile`:

``` bash
$ bundle add build-environment
```

Or install it directly:

``` bash
$ gem install build-environment
```

## Core Concepts

`build-environment` is built around {Build::Environment}, a layered hash structure implemented as a linked list. Each environment layer can override or extend the values of its parent, making it straightforward to model layered build configurations such as platform defaults, target overrides, and local project settings.

Values in an environment can be:

- **Strings**: overwrite the parent value when the environment is flattened.
- **Arrays**: concatenated with the parent value when flattened.
- **Symbols**: redirected to another key (i.e. used as an alias).
- **Lambdas/Procs**: evaluated lazily when the environment is converted to a hash.

## Usage

Create environments and chain them with a parent to inherit and override values:

``` ruby
require "build/environment"

a = Build::Environment.new
a[:cflags] = ["-std=c++11"]

b = Build::Environment.new(a, {})
b[:cflags] = ["-stdlib=libc++"]
b[:rcflags] = lambda{cflags}

b.flatten
```

When `flatten` is called, arrays are concatenated across the chain, lambdas are resolved via the evaluator, and the result is a single-layer environment ready for use.

### Constructing Environments with a Block

Use {Build::Environment#construct!} to populate an environment using a DSL block:

``` ruby
env = Build::Environment.new
env.construct!(nil) do
	cflags "-O2", "-Wall"
	ldflags "-lm"
end
```

### Merging Environments

Use {Build::Environment#merge} to create a child environment that inherits from an existing one:

``` ruby
base = Build::Environment.new(nil, cflags: ["-std=c++17"])
extended = base.merge{cflags "-stdlib=libc++"}
```

### Exporting to a Shell Environment

Use {Build::Environment::System.convert_to_shell} to produce a hash suitable for passing as a process environment:

``` ruby
shell_env = Build::Environment::System.convert_to_shell(env)
# => {"CFLAGS" => "-O2 -Wall", "LDFLAGS" => "-lm"}
```
