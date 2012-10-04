module Factories
  salt = User.make_token
  Factory.define :user do |u|
    u.active true
    u.email 'test@testing.com'
    u.salt salt
    u.crypted_password User.secure_digest('password',salt,Minimalist::Authentication::PREFERRED_DIGEST_VERSION)
    u.using_digest_version Minimalist::Authentication::PREFERRED_DIGEST_VERSION
  end
end
