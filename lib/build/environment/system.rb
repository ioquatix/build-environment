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
	class Environment
		module System
			def self.shell_escape(value)
				case value
				when Array
					value.flatten.collect{|argument| shell_escape(argument)}.join(' ')
				else
					# Ensure that any whitespace has been escaped:
					value.to_s.gsub(/ /, '\ ')
				end
			end
			
			def self.valid_for_export(value)
				case value
				when Array
					true
				when Symbol
					false
				when Proc
					false
				when Default
					false
				when Replace
					false
				when Define
					false
				else
					true
				end
			end
			
			def self.convert_to_shell(environment)
				values = environment.values.select{|key, value| valid_for_export(value)}
				
				Hash[values.map{|key, value| [
					key.to_s.upcase,
					shell_escape(value)
				]}]
			end
		end
		
		# Construct an environment from a given system environment:
		def self.system_environment(env = ENV)
			self.new(nil, Hash[env.map{|key, value| [key.downcase.to_sym, value]}])
		end
		
		# Make a hash appropriate for a process environment
		def export
			System.convert_to_shell(self)
		end
	end
end
