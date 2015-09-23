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

require 'build/environment'
require 'build/environment/system'

module Build::Environment::SystemSpec
	class Rule
		def initialize(process_name, type)
			@process_name = process_name
			@type = type
		end
		
		attr :process_name
		attr :type
	end
	
	describe Build::Environment do
		it "should not export rule" do
			a = Build::Environment.new do
				cflags "-fPIC"
				
				define Rule, "compile.foo" do
				end
			end
			
			expect(a).to include(:cflags)
			expect(a).to include('compile.foo')
			
			exported = a.export
			
			expect(exported.size).to be == 1
			expect(exported).to_not include('COMPILE.FOO')
		end
	end
end
