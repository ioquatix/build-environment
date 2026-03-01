# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

# @namespace
module Build
	# Represents a layered build environment, implemented as a linked list of hashes. It is primarily used for organising build configurations across a wide range of different sub-systems, e.g. platform configuration, target configuration, local project configuration, etc.
	class Environment
		# Initialize a new environment with an optional parent, initial values, name, and update block.
		# @parameter parent [Environment | Nil] The parent environment to inherit values from.
		# @parameter values [Hash | Nil] The initial key-value pairs for this layer.
		# @parameter name [String | Nil] An optional name for this environment.
		# @parameter block [Proc] An optional block applied when constructing the environment.
		def initialize(parent = nil, values = nil, name: nil, &block)
			@parent = parent
			@values = (values || {}).to_h
			@update = block
			
			@name = name
		end
		
		# Compare this environment with another for equality.
		# @parameter other [Environment] The environment to compare against.
		# @returns [Boolean] `true` if both environments have the same parent, values, update, and name.
		def == other
			self.equal?(other) or
				self.class == other.class and
				@parent == other.parent and
				@values == other.values and
				@update == other.update and
				@name == other.name
		end
		
		# Check equality using the `==` operator.
		# @parameter other [Environment] The environment to compare against.
		# @returns [Boolean] `true` if the environments are equal.
		def eql?(other)
			self == other
		end
		
		# Compute a hash value for this environment based on its parent, values, update, and name.
		# @returns [Integer] The computed hash value.
		def hash
			@parent.hash ^ @values.hash ^ @update.hash ^ @name.hash
		end
		
		attr :parent
		attr :values
		attr :update
		attr :name
		
		# Create a duplicate of this environment, optionally overriding parent, values, update, or name.
		# @parameter parent [Environment | Nil] The parent for the duplicate.
		# @parameter values [Hash] The values for the duplicate.
		# @parameter update [Proc | Nil] The update block for the duplicate.
		# @parameter name [String | Nil] The name for the duplicate.
		# @returns [Environment] A new environment with the given attributes.
		def dup(parent: @parent, values: @values, update: @update, name: @name)
			self.class.new(parent, values.dup, name: name, &update)
		end
		
		# Freeze this environment and its entire parent chain, making it immutable.
		# @returns [Environment] The frozen environment.
		def freeze
			return self if frozen?
			
			@parent.freeze
			@values.freeze
			@update.freeze
			
			super
		end
		
		# Find the environment layer that contains the given key.
		# @parameter name [Symbol] The key to search for.
		# @returns [Environment | Nil] The environment layer containing the key, or `nil` if not found.
		def lookup(name)
			if @values.include? name
				self
			elsif @parent
				@parent.lookup(name)
			end
		end
		
		# Check whether the key exists in this environment or any parent layer.
		# @parameter key [Symbol] The key to check.
		# @returns [Boolean | Nil] `true` if the key exists, `nil` otherwise.
		def include?(key)
			if @values.include?(key)
				true
			elsif @parent
				@parent.include?(key)
			end
		end
		
		alias :key? :include?
		
		# Count the total number of key-value pairs across all layers.
		# @returns [Integer] The total size.
		def size
			@values.size + (@parent ? @parent.size : 0)
		end
		
		# Retrieve the value for a key, with support for a default value or block.
		# @parameter key [Symbol] The key to look up.
		# @parameter default [Array] An optional default value.
		# @raises [KeyError] If the key is not found and no default or block is given.
		# @returns [Object] The value associated with the key, or the default.
		def fetch(key, *default, &block)
			if environment = lookup(key)
				return environment.values[key]
			elsif block_given?
				yield(key, *default)
			elsif !default.empty?
				return default.first
			else
				raise KeyError.new("Environment missing #{key}")
			end
		end
		
		# Retrieve the value for a key, returning `nil` if not found.
		# @parameter key [Symbol] The key to look up.
		# @returns [Object | Nil] The value, or `nil` if the key does not exist.
		def [](key)
			environment = lookup(key)
			
			environment ? environment.values[key] : nil
		end
		
		# Set the value for a key in the current environment layer.
		# @parameter key [Symbol] The key to set.
		# @parameter value [Object] The value to assign.
		def []=(key, value)
			@values[key] = value
		end
		
		# Return a human-readable string representation of this environment.
		# @returns [String] A string showing the class, name, update source location, and values.
		def to_s
			buffer = String.new("\#<#{self.class} ")
			
			if @name
				buffer << @name.inspect << " "
			end
			
			if @update
				buffer << @update.source_location.join(":") << " "
			end
			
			buffer << @values.to_s << ">"
			
			return buffer
		end
	end
end
