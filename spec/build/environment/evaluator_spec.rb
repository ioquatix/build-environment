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

require 'securerandom'

RSpec.describe Build::Environment::Evaluator do
	let(:environment) do
		Build::Environment.new do
			fruit {"apples"}
			dinner :fruit
		end
	end
	
	subject {environment.flatten.evaluator}
	
	it "can evaluate procs" do
		expect(subject.fruit).to be == "apples"
	end
	
	it "can dereference symbols" do
		expect(subject.dinner).to be == "apples"
	end
	
	context "computed values" do
		let(:environment) do
			Build::Environment.new do
				secret {SecureRandom.hex(32)}
			end
		end
		
		it "caches the computed value" do
			secret = subject.secret
			
			expect(subject.secret).to be == secret
		end
		
		describe '#dup' do
			it "retains existing cache" do
				secret = subject.secret
				
				expect(subject.dup.secret).to be == secret
			end
		end
	end
end
