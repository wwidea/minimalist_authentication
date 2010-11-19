module Factories
  Factory.define :user do |u|
    u.active true
    u.email 'test@testing.com'
    u.password 'password'
    u.password_confirmation 'password'
  end
end
