require_relative "lib/minimalist_authentication/version"

Gem::Specification.new do |s|
  s.name          = "minimalist_authentication"
  s.version       = MinimalistAuthentication::VERSION
  s.authors       = ['Aaron Baldwin', 'Brightways Learning']
  s.email         = ["baldwina@brightwayslearning.org"]
  s.homepage      = "https://github.com/wwidea/minimalist_authentication"
  s.summary       = %q{A Rails authentication plugin that takes a minimalist approach.}
  s.description   = %q{A Rails authentication plugin that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.}
  s.license       = 'MIT'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails',   '>= 5.0'
  s.add_dependency 'bcrypt',  '~> 3.1', '>= 3.1.3'
end
