guard :shell do
  directories %w(app lib test)

  # app directory
  watch(%r{^app/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }

  # views: controller test
  watch(%r{^app/views/(.+)/}) { |m| "test/controllers/#{m[1]}_controller_test.rb" }

  # mailer views: mailer test
  watch(%r{^app/views/(.+)_mailer/.+}) { |m| "test/mailers/#{m[1]}_mailer_test.rb" }

  # lib directory
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/lib/#{m[1]}_test.rb" }

  # test directories
  watch(%r{^test/.+_test\.rb$})

  # test_helper
  watch(%r{^test/test_helper\.rb$}) { "test" }
end

class Guard::Shell
  def run_all
    run_rails_test
  end

  def run_on_modifications(paths = [])
    tests = check_for_test_files(paths)
    run_rails_test(tests) if tests&.any?
  end

  private

  def check_for_test_files(paths)
    paths.select do |path|
      File.exist?(path) ? path : puts("Test file not found - #{path}")
    end
  end

  def run_rails_test(paths = [])
    puts("Running tests #{paths}") if paths&.any?
    system("bin/rails test #{paths.join(' ')}")
  end
end
