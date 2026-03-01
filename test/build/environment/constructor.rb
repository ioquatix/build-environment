# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "build/environment"

describe Build::Environment::Constructor do
	let(:proxy) {Object.new}
	let(:parent) {Build::Environment.new}
	let(:environment) {Build::Environment.new(parent)}
	let(:constructor) {subject.new(environment, proxy)}
	
	it "should set value" do
		constructor.foo :bar
		
		expect(environment[:foo]).to be == :bar
	end
	
	it "should set value to array" do
		constructor.foo :bar, :baz
		
		expect(environment[:foo]).to be == [:bar, :baz]
	end
	
	it "should set value with block" do
		constructor.foo{:bar}
		
		expect(environment[:foo].call).to be == :bar
	end
	
	it "should invoke proxy" do
		mock(proxy) do |mock|
			mock.replace(:build) do |options|
				expect(options).to be == {library: "bar"}
			end
		end
		
		constructor.build library: "bar"
	end
	
	it "should invoke proxy with block" do
		a_block = proc{}
		
		mock(proxy) do |mock|
			mock.replace(:build) do |options, &block|
				expect(options).to be == {library: "bar"}
				expect(block).to be == a_block
			end
		end
		
		constructor.build library: "bar", &a_block
	end
	
	it "cannot get value from environment" do
		environment[:foo] = "bar"
		
		expect do
			constructor.foo
		end.to raise_exception(NoMethodError)
	end
end
