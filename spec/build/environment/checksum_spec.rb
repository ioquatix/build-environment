# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

RSpec.describe "Build::Environment#checksum" do
	it "should compute a checksum" do
		e = Build::Environment.hash(a: 10, b: 20)
		
		expect(e.checksum).to be == "0e29e95023819e0ecd2850edece5851a"
	end
	
	it "should compute same checksum when keys are in different order" do
		e = Build::Environment.hash(b: 20, a: 10)
		
		expect(e.checksum).to be == "0e29e95023819e0ecd2850edece5851a"
	end
	
	it "should handle both string and symbol keys" do
		e = Build::Environment.hash(:a => 20, "b" => 10)
		
		expect(e.checksum).to be == "613a92db2cc6a94709ce3174f01c29fe"
	end
end
