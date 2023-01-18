$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "minimalist_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "minimalist_authentication"
  s.version       = MinimalistAuthentication::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Aaron Baldwin', 'Brightways Learning']
  s.email         = ["baldwina@brightwayslearning.org"]
  s.homepage      = "https://github.com/wwidea/minimalist_authentication"
  s.summary       = %q{A Rails authentication plugin that takes a minimalist approach.}
  s.description   = %q{A Rails authentication plugin that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.}
  s.license       = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails',   '>= 5.0'
  s.add_dependency 'bcrypt',  '~> 3.1', '>= 3.1.3'
end
