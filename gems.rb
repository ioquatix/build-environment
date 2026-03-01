# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project", "~> 0.18"
end

group :test do
	gem "covered"
	gem "sus"
	gem "decode"
	
	gem "rubocop"
	gem "rubocop-md"
	gem "rubocop-socketry"
	
	gem "sus-fixtures-async"
	gem "sus-fixtures-benchmark"
	
	gem "bake-test"
	gem "bake-test-external"
end

# Moved Development Dependencies
gem "covered"
gem "rspec", "~> 3.4"
gem "rake"
