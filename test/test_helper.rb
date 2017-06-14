require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = 'bin/test'

# require 'minimalist_authentication'
# require 'factory_girl'
#
# ENV["RAILS_ENV"] = "test"
# require File.expand_path('../rails_root/config/environment', __FILE__)
# require 'rails/test_help'

require File.dirname(__FILE__) + '/factories'

class ActiveSupport::TestCase
  include Factories
end
