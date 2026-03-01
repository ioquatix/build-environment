# frozen_string_literal: true

require_relative "lib/build/environment/version"

Gem::Specification.new do |spec|
	spec.name = "build-environment"
	spec.version = Build::Environment::VERSION
	
	spec.summary = "A nested hash data structure for controlling build environments."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.metadata = {
		"documentation_uri" => "https://ioquatix.github.io/build-environment",
		"funding_uri" => "https://github.com/sponsors/ioquatix",
		"source_code_uri" => "https://github.com/ioquatix/build-environment",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "ostruct"
end
