# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "build/environment"
require "build/environment/flatten"

describe Build::Environment do
	it "preserves name of top level environment" do
		a = subject.new(name: "a")
		b = subject.new(a, name: "b")
		c = b.flatten
		
		expect(c.name).to be == "b"
	end
	
	it "uses name if specified" do
		a = subject.new(name: "a")
		b = subject.new(a, name: "b")
		c = b.flatten(name: "c")
		
		expect(c.name).to be == "c"
	end
end
