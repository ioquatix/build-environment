# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2026, by Samuel Williams.

require "build/environment"
require "build/environment/system"

describe Build::Environment do
	it "can execute update functions" do
		platform = Build::Environment.new do
			libraries []
			
			root "/usr"
			bin ->{File.join(root, "bin")}
			compiler ->{File.join(bin, "clang")}
			
			append libraries "m"
		end
		
		task = Build::Environment.new(platform) do
			library_path = File.join(parent.checksum, "Time.a")
			
			append libraries library_path
		end
		
		environment = task.flatten do |environment|
			environment.update!
		end
		
		expect(environment[:libraries].count).to be == 2
	end
end
