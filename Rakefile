require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the minimalist_authentication plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the minimalist_authentication plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MinimalistAuthentication'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Measures test coverage using rcov'
task :rcov do
  rm_f "coverage"
  rcov = "rcov --rails --text-summary -Ilib --exclude /gems/,/app/,/Library/"
  system("#{rcov} --html #{Dir.glob('test/**/*_test.rb').join(' ')}")
  if PLATFORM['darwin'] #Mac
    system("open coverage/index.html")
  elsif PLATFORM[/linux/] #Ubuntu, etc.
    system("/etc/alternatives/x-www-browser coverage/index.html")
  end
end
