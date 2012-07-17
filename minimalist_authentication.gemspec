require File.expand_path('../lib/minimalist/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "minimalist_authentication"
  s.version = MinimalistAuthentication::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Aaron Baldwin', 'Jonathan S. Garvin', 'WWIDEA, Inc']
  s.email = ["developers@wwidea.org"]
  s.homepage = "https://github.com/wwidea/minimalist_authentication"
  s.summary = %q{A Rails authentication plugin that takes a minimalist approach.}
  s.description = %q{A Rails authentication plugin that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.}
  
  s.add_dependency('bcrypt-ruby', '~> 3.0.1')

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
end