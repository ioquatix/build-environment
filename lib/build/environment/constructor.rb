# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		Default = Struct.new(:value)
		Replace = Struct.new(:value)
		
		class Define < Struct.new(:klass, :block)
			def initialize(klass, &block)
				super klass, block
			end
			
			def to_s
				"#<#{klass} #{block ? block.source_location.join(':') : 'unknown'}>"
			end
		end
		
		def construct!(proxy, *arguments, &block)
			constructor = Constructor.new(self, proxy)
			
			if block_given?
				constructor.instance_exec(*arguments, &block)
			end
			
			return self
		end
		
		class Constructor
			def initialize(environment, proxy = nil)
				@environment = environment
				@proxy = proxy
			end
			
			def respond_to?(name, include_private = false)
				@environment.include?(name) || @proxy&.respond_to?(name, include_private) || super
			end
			
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
			
			def respond_to(*args)
				super or @proxy&.respond_to(*args)
			end
			
			def [] key
				@environment[key]
			end
			
			def parent
				@environment.parent
			end
			
			def hash(**options)
				OpenStruct.new(options)
			end
			
			def default(name)
				@environment[name] = Default.new(@environment[name])
				
				return name
			end
			
			def replace(name)
				@environment[name] = Replace.new(@environment[name])
				
				return name
			end
			
			def append(name)
				@environment[name] = Array(@environment[name])
				
				return name
			end
			
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
		
		def merge(**options, &block)
			self.class.new(self, **options, &block)
		end
		
		# Convert the hierarchy of environments to an array where the parent comes before the child.
		def to_a
			flat = []
			
			flatten_to_array(flat)
			
			return flat
		end
		
		def flatten_to_array(array)
			if @parent
				@parent.flatten_to_array(array)
			end
			
			array << self
		end
	end
end
