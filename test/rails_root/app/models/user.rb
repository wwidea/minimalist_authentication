class User < ActiveRecord::Base
  include Minimalist::Authentication
end
