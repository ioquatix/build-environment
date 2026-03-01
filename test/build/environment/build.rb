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
			constructor = Build::Environment::Constructor.new(flat_environment)
			constructor.instance_exec(&define.block)
		end
		
		expect(flat_environment).to be(:include?, :libraries)
		expect(flat_environment[:libraries]).to be(:include?, static_library)
	end
end
