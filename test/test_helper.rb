require 'minimalist_authentication'
require 'factory_girl'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../rails_root/config/environment', __FILE__)
require 'rails/test_help'

require File.dirname(__FILE__) + '/factories'

class ActiveSupport::TestCase
  include Factories
end
