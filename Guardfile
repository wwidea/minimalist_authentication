guard :minitest do
  watch(%r{^app/(.+)\.rb$})                           { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/minimalist_authentication/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$})                   { 'test' }
end
