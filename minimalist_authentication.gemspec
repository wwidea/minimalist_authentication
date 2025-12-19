# frozen_string_literal: true

require_relative "lib/minimalist_authentication/version"

RAILS_VERSION_REQUIREMENT = ">= 7.1.0"

Gem::Specification.new do |spec|
  spec.name          = "minimalist_authentication"
  spec.version       = MinimalistAuthentication::VERSION
  spec.authors       = ["Aaron Baldwin", "Brightways Learning"]
  spec.email         = ["baldwina@brightwayslearning.org"]
  spec.homepage      = "https://github.com/wwidea/minimalist_authentication"
  spec.summary       = "A Rails authentication plugin that takes a minimalist approach."
  spec.description   = "A Rails authentication plugin that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application."
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 3.2.0"
  spec.add_dependency "actionmailer", RAILS_VERSION_REQUIREMENT
  spec.add_dependency "activerecord", RAILS_VERSION_REQUIREMENT
  spec.add_dependency "bcrypt", "~> 3.1", ">= 3.1.3"
  spec.add_dependency "railties", RAILS_VERSION_REQUIREMENT
end
