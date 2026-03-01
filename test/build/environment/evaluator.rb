# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "build/environment"

require "securerandom"

describe Build::Environment::Evaluator do
	let(:environment) do
		Build::Environment.new do
			fruit {"apples"}
			dinner :fruit
		end
	end
	
	let(:evaluator) {environment.flatten.evaluator}
	
	it "can evaluate procs" do
		expect(evaluator.fruit).to be == "apples"
	end
	
	it "can dereference symbols" do
		expect(evaluator.dinner).to be == "apples"
	end
	
	with "computed values" do
		let(:environment) do
			Build::Environment.new do
				secret {SecureRandom.hex(32)}
			end
		end
		
		it "caches the computed value" do
			secret = evaluator.secret
			
			expect(evaluator.secret).to be == secret
		end
		
		describe "#dup" do
			it "retains existing cache" do
				secret = evaluator.secret
				
				expect(evaluator.dup.secret).to be == secret
			end
		end
	end
end
