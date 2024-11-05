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
bin/rails generate model user active:boolean email:string password_digest:string last_logged_in_at:datetime
```

OR create a user model with **username** for an identifier:
```bash
bin/rails generate model user active:boolean username:string password_digest:string last_logged_in_at:datetime
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

## Configuration
Customize the configuration with an initializer. Create a **minimalist_authentication.rb** file in config/initializers.
```ruby
MinimalistAuthentication.configure do |configuration|
  configuration.user_model_name           = 'CustomModelName'   # default is '::User'
  configuration.session_key               = :custom_session_key # default is :user_id
  configuration.validate_email            = true                # default is true
  configuration.validate_email_presence   = true                # default is true
  configuration.request_email             = true                # default is true
  configuration.verify_email              = true                # default is true
  configuration.login_redirect_path       = :custom_path        # default is :root_path
  configuration.logout_redirect_path      = :custom_path        # default is :new_session_path
end
```


## Fixtures
Use **MinimalistAuthentication::TestHelper::PASSWORD_DIGEST** to create a password_digest for fixture users.
```yaml
example_user:
  email:            user@example.com
  password_digest:  <%= MinimalistAuthentication::TestHelper::PASSWORD_DIGEST %>
```


## Verification Tokens
Verification token support is provided by the **MinimalistAuthentication::VerifiableToken**
module. Include the module in your user class and add the verification token columns
to the database.

Include MinimalistAuthentication::VerifiableToken in your user model (app/models/user.rb)
```ruby
class User < ApplicationRecord
  include MinimalistAuthentication::User
  include MinimalistAuthentication::VerifiableToken
end
```

Add the **verification_token** and **verification_token_generated_at** columns:
Create a user model with **email** for an identifier:
```bash
bin/rails generate migration AddVerificationTokenToUsers verification_token:string:uniq verification_token_generated_at:datetime
```

### Email Verification
Include MinimalistAuthentication::EmailVerification in your user model (app/models/user.rb)
```ruby
class User < ApplicationRecord
  include MinimalistAuthentication::User
  include MinimalistAuthentication::VerifiableToken
  include MinimalistAuthentication::EmailVerification
end
```

Add the **email_verified_at** column to your user model:
```bash
bin/rails generate migration AddEmailVerifiedAtToUsers email_verified_at:datetime
```


## Conversions

### Upgrading to Version 2.0
Pre 2.0 versions of MinimalistAuthentication supported multiple hash algorithms
and stored the hashed password and salt as separate fields in the database
(crypted_password and salt). The current version of MinimalistAuthentication
uses BCrypt to hash passwords and stores the result in the **password_hash** field.

To convert from a pre 2.0 version add the **password_hash** to your user model
and run the conversion routine.
```bash
bin/rails generate migration AddPasswordHashToUsers password_hash:string
```
```ruby
MinimalistAuthentication::Conversions::MergePasswordHash.run!
```

When the conversion is complete the **crypted_password**, **salt**, and
**using_digest_version** fields can safely be removed.

### Upgrading to Version 3.0
Version 3.0 of MinimalistAuthentication uses the Rails has_secure_password for authentication. This change requires either renaming the **password_hash** column to **password_digest** or adding an alias_attribute to map **password_digest** to **password_hash**.

#### Rename the **password_hash** column to **password_digest**
Add a migration to rename the column in your users table:
```bash
bin/rails generate migration rename_users_password_hash_to_password_digest
```

Update the change method:
```ruby
def change
  rename_column :users, :password_hash, :password_digest
end
```

#### Alternatively, add **alias_attribute** to your user model
```ruby
alias_attribute :password_digest, :password_hash
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT)..
