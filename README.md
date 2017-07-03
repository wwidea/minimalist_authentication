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

Create a user model:
```bash
bin/rails generate model user active:boolean email:string crypted_password:string salt:string using_digest_version:integer last_logged_in_at:datetime
```


## Example
Include Minimalist::Authentication in your user model (app/models/user.rb)
```ruby
class User < ApplicationRecord
  include Minimalist::Authentication
end
```

Include Minimalist::Authorization in your ApplicationController (app/controllers/application.rb)
```ruby
class ApplicationController < ActionController::Base
  include Minimalist::Authorization
  
  # Lock down everything by default
  # use skip_before_action to open up specific actions
  before_action :authorization_required
end
```

Include Minimalist::Sessions in your SessionsController (app/controllers/sessions_controller.rb)
```ruby
class SessionsController < ApplicationController
  include Minimalist::Sessions
  skip_before_action :authorization_required, only: %i(new create)
end
```

Include Minimalist::TestHelper in your test helper (test/test_helper.rb)
```ruby
class ActiveSupport::TestCase
  include Minimalist::TestHelper
end
```


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
