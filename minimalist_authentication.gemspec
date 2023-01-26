require_relative "lib/minimalist_authentication/version"

Gem::Specification.new do |spec|
  spec.name          = "minimalist_authentication"
  spec.version       = MinimalistAuthentication::VERSION
  spec.authors       = ["Aaron Baldwin", "Brightways Learning"]
  spec.email         = ["baldwina@brightwayslearning.org"]
  spec.homepage      = "https://github.com/wwidea/minimalist_authentication"
  spec.summary       = %q{A Rails authentication plugin that takes a minimalist approach.}
  spec.description   = %q{A Rails authentication plugin that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.}
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails",  ">= 5.0"
  spec.add_dependency "bcrypt", "~> 3.1", ">= 3.1.3"
end
