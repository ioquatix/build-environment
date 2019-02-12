# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Build
	# This is the basic environment data structure which is essentially a linked list of hashes. It is primarily used for organising build configurations across a wide range of different sub-systems, e.g. platform configuration, target configuration, local project configuration, etc.
	class Environment
		def initialize(parent = nil, values = nil, update = nil, &block)
			@parent = parent
			@values = (values || {}).to_h
			@update = update || block
			
			@constructor = nil
		end
		
		def dup(parent: @parent, values: @values, update: @update)
			self.class.new(parent, values.dup, update)
		end
		
		attr_accessor :update
		
		def update!(*arguments)
			self.dup(update: nil).tap do |environment|
				environment.constructor.instance_exec(*arguments, &@update)
			end
		end
		
		# Apply the update function to this environment.
		def update!(*arguments, &block)
			if block_given?
				yield self
			else
				self.constructor.instance_exec(*arguments, &@update)

				@update = nil
			end
			
			return self
		end
		
		def constructor
			raise FrozenError, "Cannot update frozen environment!" if frozen?
			
			@constructor ||= Constructor.new(self)
		end
		
		def freeze
			return self if frozen?
			
			@parent.freeze
			@values.freeze
			@update.freeze
			
			super
		end
		
		def self.hash(values = {})
			self.new(nil, values)
		end
		
		attr :values
		attr :parent
		
		def lookup(name)
			if @values.include? name
				self
			elsif @parent
				@parent.lookup(name)
			end
		end
		
		def include?(key)
			lookup(key) != nil
		end
		
		def size
			@values.size + (@parent ? @parent.size : 0)
		end
		
		def [](key)
			environment = lookup(key)
			
			environment ? environment.values[key] : nil
		end
		
		def []=(key, value)
			@values[key] = value
		end
		
		def to_s
			buffer = String.new("\#<#{self.class} ")
			
			if @update
				buffer << @update.source_location.join(':') << ' '
			end
			
			buffer << @values.to_s << '>'
			
			return buffer
		end
	end
end
