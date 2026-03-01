# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

require "build/environment"

describe "Build::Environment#checksum" do
	it "should compute a checksum" do
		e = Build::Environment.new do
			a 10
			b 20
		end.evaluate
		
		expect(e.checksum).to be == "3a781e8f5250ccb2bca472085a4e366188621d8a"
	end
	
	it "should compute same checksum when keys are in different order" do
		e = Build::Environment.new do
			b 20
			a 10
		end.evaluate
		
		expect(e.checksum).to be == "3a781e8f5250ccb2bca472085a4e366188621d8a"
	end
end
