# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "build/environment"
require "build/environment/system"

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
		end.flatten
		
		expect(a).to be(:include?, :cflags)
		expect(a).to be(:include?, "compile.foo")
		
		exported = a.export
		
		expect(exported.size).to be == 1
		expect(exported).not.to be(:include?, "COMPILE.FOO")
	end
	
	let(:system_environment) {Build::Environment.system_environment}
	
	it "shold load current ENV" do
		ENV["TEST_KEY"] = "test-value"
		
		expect(system_environment).to have_keys(:path, :user, :home)
		expect(system_environment[:test_key]).to be == "test-value"
	end
end
