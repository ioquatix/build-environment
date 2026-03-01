# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		class Evaluator
			def initialize(environment)
				@environment = environment
				@cache = {}
			end
			
			def initialize_dup(other)
				@environment = other.instance_variable_get(:@environment)
				@cache = other.instance_variable_get(:@cache).dup
				
				super
			end
			
			def respond_to?(name, include_private = false)
				@environment.include?(name) || super
			end
			
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
