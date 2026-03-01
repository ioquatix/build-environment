# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

module Build
	class Environment
		# Provides utilities for converting environment values to shell-compatible strings.
		module System
			# Escape a value for safe use in a shell command string.
			# @parameter value [String | Array] The value to escape.
			# @returns [String] The shell-escaped string.
			def self.shell_escape(value)
				case value
				when Array
					value.flatten.collect{|argument| shell_escape(argument)}.join(" ")
				else
					# Ensure that any whitespace has been escaped:
					value.to_s.gsub(/ /, '\ ')
				end
			end
			
			# Check whether a value is suitable for export to a shell environment.
			# @parameter value [Object] The value to check.
			# @returns [Boolean] `true` if the value can be exported, `false` otherwise.
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
			
			# Convert an environment to a shell-compatible hash with uppercase string keys and escaped string values.
			# @parameter environment [Environment] The environment to convert.
			# @returns [Hash] A hash of uppercase string keys mapped to shell-escaped string values.
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
