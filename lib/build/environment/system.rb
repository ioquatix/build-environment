# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		module System
			def self.shell_escape(value)
				case value
				when Array
					value.flatten.collect{|argument| shell_escape(argument)}.join(" ")
				else
					# Ensure that any whitespace has been escaped:
					value.to_s.gsub(/ /, '\ ')
				end
			end
			
			def self.valid_for_export(value)
				case value
				when Array
					true
				when Symbol
					false
				when Proc
					false
				when Default
					false
				when Replace
					false
				when Define
					false
				else
					true
				end
			end
			
			def self.convert_to_shell(environment)
				values = environment.values.select{|key, value| valid_for_export(value)}
				
				Hash[values.map{|key, value| [
					key.to_s.upcase,
					shell_escape(value)
				]}]
			end
		end
		
		# Construct an environment from a given system environment:
		def self.system_environment(env = ENV, **options)
			self.new(nil, Hash[env.map{|key, value| [key.downcase.to_sym, value]}], **options)
		end
		
		# Make a hash appropriate for a process environment
		def export
			System.convert_to_shell(self)
		end
	end
end
