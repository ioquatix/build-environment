#!/usr/bin/env rspec
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

require "build/environment"

describe "Build::Environment#freeze" do
	it "should not be frozen by default" do
		a = Build::Environment.new
		b = a.merge
		
		expect(a.frozen?).to be_falsey
		expect(b.frozen?).to be_falsey
		expect(b.parent).to be_equal(a)
	end
	
	it "should freeze an environment and it's parent" do
		a = Build::Environment.new
		b = a.merge
		
		b.freeze
		
		expect(a.frozen?).to be_truthy
		expect(b.frozen?).to be_truthy
	end
	
	it "should only be partially frozen" do
		a = Build::Environment.new
		b = a.merge
		
		a.freeze
		
		expect(a.frozen?).to be_truthy
		expect(b.frozen?).to be_falsey
	end
end
