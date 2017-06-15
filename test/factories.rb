module Factories
  salt = User.make_token
  
  FactoryGirl.define do
    factory :user do
      active                true
      email                 'test-old@testing.com'
      salt                  salt
      crypted_password      User.secure_digest('password', salt)
      using_digest_version  Minimalist::Authentication::PREFERRED_DIGEST_VERSION
    end
  end
end
