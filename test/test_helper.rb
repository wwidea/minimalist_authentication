ENV["RAILS_ENV"] = "test"
require File.expand_path('../rails_root/config/environment', __FILE__)
require 'rails/test_help'

# require 'test/unit'
# require 'rubygems'
# gem 'actionpack', '= 3.0.3'
# gem 'activerecord', '= 3.0.3'
# gem 'activesupport', '= 3.0.3'
# require 'action_controller'
# require 'active_record'
# require 'active_support/test_case'
# require 'active_support/core_ext/logger'
require File.dirname(__FILE__) + '/../init'
require File.dirname(__FILE__) + '/factories'

class Test::Unit::TestCase
  include Factories
  
  class << self
    def load_schema
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      load(File.dirname(__FILE__) + "/schema.rb")
    end
  end
  
  def teardown
    User.delete_all
  end
end

class User < ActiveRecord::Base
  include Minimalist::Authentication
end
