# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

require "digest/md5"
require "ostruct"

module Build
	class Environment
		def to_h
			hash = {}
			
			# Flatten this chain of environments:
			flatten_to_hash(hash)
			
			# Evaluate all items to their respective object value:
			evaluator = Evaluator.new(hash)
			
			# Evaluate all the individual environment values so that they are flat:
			Hash[hash.map{|key, value| [key, evaluator.object_value(value)]}]
		end
		
		def evaluator
			Evaluator.new(self)
		end
		
		def evaluate(**options)
			self.class.new(nil, self.to_h, **options)
		end
		
		def flatten(**options)
			hash = {}
			
			flatten_to_hash(hash)
			
			options[:name] ||= self.name
			
			return self.class.new(nil, hash, **options)
		end
		
		def defined
			@values.select{|name,value| Define === value}
		end
		
		def checksum(digester: Digest::SHA1.new)
			checksum_recursively(digester)
			
			return digester.hexdigest
		end
		
		protected
		
		def sorted_keys
			@values.keys.sort_by(&:to_s)
		end
		
		def checksum_recursively(digester)
			sorted_keys.each do |key|
				digester.update(key.to_s)
				
				case value = @values[key]
				when Proc
					digester.update(value.source_location.join)
				else
					digester.update(value.to_s)
				end
			end
			
			@parent.checksum_recursively(digester) if @parent
		end
		
		def update_hash(hash)
			@values.each do |key, value|
				previous = hash[key]
				
				if Replace === value
					# Replace the parent value
					hash[key] = value
				elsif Default === value
					# Update the parent value if not defined.
					hash[key] = previous || value
				elsif Array === previous
					# Merge with the parent value
					hash[key] = previous + Array(value)
				elsif OpenStruct === value
					hash[key] = value.to_h
				else
					hash[key] = value
				end
			end
			
			return self
		end
		
		# Apply the update function to this environment.
		def update!
			construct!(self, &@update)
			@update = nil
			
			return self
		end
		
		# We fold in the ancestors one at a time from oldest to youngest.
		def flatten_to_hash(hash)
			if parent = @parent
				parent = parent.flatten_to_hash(hash)
			end
			
			if @update
				self.dup(parent: parent).update!.update_hash(hash)
			else
				self.update_hash(hash)
			end
		end
	end
end
