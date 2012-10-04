class User < ActiveRecord::Base
  include Minimalist::Authentication
  attr_protected :crypted_password, :salt, :using_digest_version
end
