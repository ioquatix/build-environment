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
		include Comparable
		
		def initialize(parent = nil, values = nil, name: nil, &block)
			@parent = parent
			@values = (values || {}).to_h
			@update = block
			
			@name = name
		end
		
		attr :parent
		attr :values
		attr :update
		attr :name
		
		def dup(parent: @parent, values: @values, update: @update, name: @name)
			self.class.new(parent, values.dup, name: name, &update)
		end
		
		def <=> other
			self.to_h <=> other.to_h
		end
		
		def freeze
			return self if frozen?
			
			@parent.freeze
			@values.freeze
			@update.freeze
			
			super
		end
		
		def lookup(name)
			if @values.include? name
				self
			elsif @parent
				@parent.lookup(name)
			end
		end
		
		def include?(key)
			if @values.include?(key)
				true
			elsif @parent
				@parent.include?(key)
			end
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
			
			if @name
				buffer << @name.inspect << ' '
			end
			
			if @update
				buffer << @update.source_location.join(':') << ' '
			end
			
			buffer << @values.to_s << '>'
			
			return buffer
		end
	end
end
