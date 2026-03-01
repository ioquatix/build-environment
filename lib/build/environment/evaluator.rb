# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		# Represents a lazy evaluator that resolves and caches environment values on demand.
		class Evaluator
			# Initialize the evaluator with an environment.
			# @parameter environment [Environment] The environment whose values will be evaluated.
			def initialize(environment)
				@environment = environment
				@cache = {}
			end
			
			# Copy the environment reference and cache when duplicating.
			# @parameter other [Evaluator] The evaluator being duplicated.
			def initialize_dup(other)
				@environment = other.instance_variable_get(:@environment)
				@cache = other.instance_variable_get(:@cache).dup
				
				super
			end
			
			# Check whether the evaluator responds to a given method name.
			# @parameter name [Symbol] The method name to check.
			# @parameter include_private [Boolean] Whether to include private methods.
			# @returns [Boolean] `true` if the environment contains the key or the evaluator responds via `super`.
			def respond_to?(name, include_private = false)
				@environment.include?(name) || super
			end
			
			# Evaluate and cache the value for the named key.
			# @parameter name [Symbol] The key to resolve from the environment.
			# @returns [Object] The resolved and cached value.
			def method_missing(name)
				@cache[name] ||= object_value(@environment[name])
			end
			
			# Compute the literal object value for a given key:
			def object_value(value)
				case value
				when Array
					value.collect{|item| object_value(item)}.flatten
				when Symbol
					object_value(@environment[value])
				when Proc
					object_value(instance_exec(&value))
				when Default
					object_value(value.value)
				when Replace
					object_value(value.value)
				else
					value
				end
			end
		end
	end
end
