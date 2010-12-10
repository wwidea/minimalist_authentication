require 'test/unit'
require 'rubygems'
gem 'actionpack', '= 2.3.10'
gem 'activerecord', '= 2.3.10'
gem 'activesupport', '= 2.3.10'
gem 'factory_girl'
require 'action_controller'
require 'active_record'
require 'active_support/test_case'
require File.dirname(__FILE__) + '/../init'
require File.dirname(__FILE__) + '/factories'

class Test::Unit::TestCase
  include Factories
  
  class << self
    def load_schema
      ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
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
