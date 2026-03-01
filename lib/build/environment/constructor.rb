# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		Default = Struct.new(:value)
		Replace = Struct.new(:value)
		
		# Represents a deferred class instantiation, binding a class and a configuration block to an environment key.
		class Define < Struct.new(:klass, :block)
			# Initialize a define with a class and an optional configuration block.
			# @parameter klass [Class] The class to instantiate.
			# @parameter block [Proc] An optional block used to configure the instance.
			def initialize(klass, &block)
				super klass, block
			end
			
			# Return a string representation of this define.
			# @returns [String] A string showing the class and block source location.
			def to_s
				"#<#{klass} #{block ? block.source_location.join(':') : 'unknown'}>"
			end
		end
		
		# Apply a block to this environment using a {Constructor} proxy, then return the environment.
		# @parameter proxy [Object | Nil] An optional proxy object to delegate unknown method calls to.
		# @parameter arguments [Array] Arguments forwarded to the block.
		# @returns [Environment] The updated environment.
		def construct!(proxy, *arguments, &block)
			constructor = Constructor.new(self, proxy)
			
			if block_given?
				constructor.instance_exec(*arguments, &block)
			end
			
			return self
		end
		
		# Represents a DSL proxy used to populate an environment using a block-based interface.
		class Constructor
			# Initialize the constructor with an environment and an optional proxy object.
			# @parameter environment [Environment] The environment to populate.
			# @parameter proxy [Object | Nil] An optional proxy for delegating unknown method calls.
			def initialize(environment, proxy = nil)
				@environment = environment
				@proxy = proxy
			end
			
			# Check whether the constructor responds to the given method name.
			# @parameter name [Symbol] The method name to check.
			# @parameter include_private [Boolean] Whether to include private methods.
			# @returns [Boolean] `true` if the environment includes the key or the proxy responds to the method.
			def respond_to?(name, include_private = false)
				@environment.include?(name) || @proxy&.respond_to?(name, include_private) || super
			end
			
			# Dynamically set environment keys or delegate to the proxy object.
			# @parameter name [Symbol] The key name or proxy method name.
			# @parameter args [Array] Positional arguments: a single value, multiple values, or none (with a block).
			# @parameter options [Hash] Keyword arguments forwarded to the proxy.
			# @parameter block [Proc] A block used as the value when no positional arguments are given.
			def method_missing(name, *args, **options, &block)
				if options.empty?
					if args.empty? and block_given?
						@environment[name] = block
						
						return name
					elsif !args.empty?
						if args.count == 1
							@environment[name] = args.first
						else
							@environment[name] = args
						end
						
						return name
					end
				end
				
				if @proxy
					# This is a bit of a hack, but I'm not sure if there is a better way.
					if options.empty?
						@proxy.send(name, *args, &block)
					else
						@proxy.send(name, *args, **options, &block)
					end
				else
					super
				end
			end
			
			# Delegate `respond_to` to the proxy if available.
			# @returns [Boolean] `true` if the constructor or proxy responds to the given arguments.
			def respond_to(*args)
				super or @proxy&.respond_to(*args)
			end
			
			# Retrieve the value of a key from the underlying environment.
			# @parameter key [Symbol] The key to look up.
			# @returns [Object | Nil] The value associated with the key.
			def [] key
				@environment[key]
			end
			
			# Return the parent of the underlying environment.
			# @returns [Environment | Nil] The parent environment.
			def parent
				@environment.parent
			end
			
			# Create an `OpenStruct` from the given keyword options.
			# @parameter options [Hash] The key-value pairs for the struct.
			# @returns [OpenStruct] A new struct with the given options.
			def hash(**options)
				OpenStruct.new(options)
			end
			
			# Mark the current value of a key as the default, wrapping it in a `Default` struct.
			# @parameter name [Symbol] The key whose value should be treated as a default.
			# @returns [Symbol] The key name.
			def default(name)
				@environment[name] = Default.new(@environment[name])
				
				return name
			end
			
			# Mark the current value of a key for replacement, wrapping it in a `Replace` struct.
			# @parameter name [Symbol] The key whose value should be replaced.
			# @returns [Symbol] The key name.
			def replace(name)
				@environment[name] = Replace.new(@environment[name])
				
				return name
			end
			
			# Convert the current value of a key to an array to allow appending.
			# @parameter name [Symbol] The key whose value should be converted to an array.
			# @returns [Symbol] The key name.
			def append(name)
				@environment[name] = Array(@environment[name])
				
				return name
			end
			
			# Associate a class and configuration block with a key as a `Define` struct.
			# @parameter klass [Class] The class to associate with the key.
			# @parameter name [Symbol] The key to define.
			# @parameter block [Proc] A block used to configure the class instance.
			# @returns [Symbol] The key name.
			def define(klass, name, &block)
				@environment[name] = Define.new(klass, &block)
				
				return name
			end
		end
		
		# Flatten the list of environments.
		def self.combine(*environments)
			ordered = []
			
			environments.each do |environment|
				environment.flatten_to_array(ordered)
			end
			
			ordered.inject(nil) do |parent, environment|
				environment.dup(parent: parent)
			end
		end
		
		# Create a new child environment inheriting from this one, with optional keyword options and block.
		# @parameter options [Hash] Options forwarded to the new environment's constructor.
		# @parameter block [Proc] An optional update block for the new environment.
		# @returns [Environment] A new environment with `self` as the parent.
		def merge(**options, &block)
			self.class.new(self, **options, &block)
		end
		
		# Convert the hierarchy of environments to an array where the parent comes before the child.
		def to_a
			flat = []
			
			flatten_to_array(flat)
			
			return flat
		end
		
		# Recursively collect this environment and its ancestors into an array, parent first.
		# @parameter array [Array] The array to append environments into.
		def flatten_to_array(array)
			if @parent
				@parent.flatten_to_array(array)
			end
			
			array << self
		end
	end
end
