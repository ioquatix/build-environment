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

RSpec.describe Build::Environment::Constructor do
	let(:proxy) {Object.new}
	let(:environment) {Build::Environment.new(nil)}
	subject{described_class.new(environment, proxy)}
	
	it "should set value" do
		subject.foo :bar
		
		expect(environment[:foo]).to be == :bar
	end
	
	it "should set value to array" do
		subject.foo :bar, :baz
		
		expect(environment[:foo]).to be == [:bar, :baz]
	end
	
	it "should set value with block" do
		subject.foo {:bar}
		
		expect(environment[:foo].call).to be == :bar
	end
	
	it "should invoke proxy" do
		expect(proxy).to receive(:build).with(library: 'bar')
		
		subject.build library: 'bar'
	end
	
	it "should invoke proxy with block" do
		a_block = proc{}
		
		expect(proxy).to receive(:build).with(library: 'bar') do |&block|
			expect(block).to be a_block
		end
		
		subject.build library: 'bar', &a_block
	end
	
	it "cannot get values" do
		subject.foo :bar
		expect do
			subject.foo
		end.to raise_error(NoMethodError)
	end
end
