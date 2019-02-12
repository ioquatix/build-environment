# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'rule'

RSpec.describe Build::Environment do
	it "should update environment" do
		static_library = "Freeb.a"
		
		environment = Build::Environment.new do
			libraries []
			
			define Rule, "link.static-library" do
				append libraries static_library
			end
		end.flatten
		
		rules = environment.defined
		
		flat_environment = environment.flatten
		
		rules.each do |name, define|
			flat_environment.constructor.instance_exec(&define.block)
		end
		
		expect(flat_environment).to include(:libraries)
		expect(flat_environment[:libraries]).to include(static_library)
	end
end
