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

Create a user model for with **email** for an identifier:
```bash
bin/rails generate model user active:boolean email:string crypted_password:string salt:string last_logged_in_at:datetime
```

OR create a user model with **username** for an identifier:
```bash
bin/rails generate model user active:boolean username:string crypted_password:string salt:string last_logged_in_at:datetime
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

Include Minimalist::Sessions in your SessionsController (app/controllers/sessions_controller.rb)
```ruby
class SessionsController < ApplicationController
  include Minimalist::Sessions
end
```

Include Minimalist::TestHelper in your test helper (test/test_helper.rb)
```ruby
class ActiveSupport::TestCase
  include MinimalistAuthentication::TestHelper
end
```

## Build
[![Build Status](https://travis-ci.org/wwidea/minimalist_authentication.svg?branch=master)](https://travis-ci.org/wwidea/minimalist_authentication)


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
