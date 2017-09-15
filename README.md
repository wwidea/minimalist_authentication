# MinimalistAuthentication
A Rails authentication gem that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'minimalist_authentication'
```

And then execute:
```bash
$ bundle
```

Create a user model with **email** for an identifier:
```bash
bin/rails generate model user active:boolean email:string password_hash:string last_logged_in_at:datetime
```

OR create a user model with **username** for an identifier:
```bash
bin/rails generate model user active:boolean username:string password_hash:string last_logged_in_at:datetime
```


## Example
Include MinimalistAuthentication::User in your user model (app/models/user.rb)
```ruby
class User < ApplicationRecord
  include MinimalistAuthentication::User
end
```

Include MinimalistAuthentication::Controller in your ApplicationController (app/controllers/application.rb)
```ruby
class ApplicationController < ActionController::Base
  include MinimalistAuthentication::Controller
end
```

Include MinimalistAuthentication::Sessions in your SessionsController (app/controllers/sessions_controller.rb)
```ruby
class SessionsController < ApplicationController
  include MinimalistAuthentication::Sessions
end
```

Add session to your routes file (config/routes.rb)
```ruby
Rails.application.routes.draw do
  resource :session, only: %i(new create destroy)
end
```

Include Minimalist::TestHelper in your test helper (test/test_helper.rb)
```ruby
class ActiveSupport::TestCase
  include MinimalistAuthentication::TestHelper
end
```

## Example
Customize the configuration with an initializer. Create a **minimalist_authentication.rb** file in /Users/baldwina/git/brightways/config/initializers.
```ruby
MinimalistAuthentication.configure do |configuration|
  configuration.user_model_name   = 'CustomModelName'     # default is '::User'
  configuration.session_key       = :custom_session_key   # default is ':user_id'
end
```

## Build
[![Build Status](https://travis-ci.org/wwidea/minimalist_authentication.svg?branch=master)](https://travis-ci.org/wwidea/minimalist_authentication)


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
