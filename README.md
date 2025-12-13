# MinimalistAuthentication

A Rails authentication gem that takes a minimalist approach. It is designed to be simple to understand, use, and customize for your application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "minimalist_authentication"
```

And then run:

```bash
bundle
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

Create a Current class that inherits from ActiveSupport::CurrentAttributes with a user attribute (app/models/current.rb)

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
```

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
  configuration.account_setup_duration      = 3.days              # default: 1.day
  configuration.email_verification_duration = 30.minutes          # default: 1.hour
  configuration.login_redirect_path         = :custom_path        # default: :root_path
  configuration.logout_redirect_path        = :custom_path        # default: :new_session_path
  configuration.password_reset_duration     = 30.minutes          # default: 1.hour
  configuration.request_email               = true                # default: true
  configuration.session_key                 = :custom_session_key # default: :user_id
  configuration.user_model_name             = "CustomModelName"   # default: "::User"
  configuration.validate_email              = true                # default: true
  configuration.validate_email_presence     = true                # default: true
  configuration.verify_email                = true                # default: true
end
```

### Example with a Person Model

```ruby
MinimalistAuthentication.configure do |configuration|
  configuration.login_redirect_path     = :dashboard_path
  configuration.session_key             = :person_id
  configuration.user_model_name         = "Person"
  configuration.validate_email_presence = false
end
```

## Fixtures

Use **MinimalistAuthentication::TestHelper::PASSWORD_DIGEST** to create a password_digest for fixture users.

```yaml
example_user:
  email: user@example.com
  password_digest: <%= MinimalistAuthentication::TestHelper::PASSWORD_DIGEST %>
```

## Email Verification

Include MinimalistAuthentication::EmailVerification in your user model (app/models/user.rb)

```ruby
class User < ApplicationRecord
  include MinimalistAuthentication::User
  include MinimalistAuthentication::EmailVerification
end
```

Add the **email_verified_at** column to your user model:

```bash
bin/rails generate migration AddEmailVerifiedAtToUsers email_verified_at:datetime
```

## Verification Tokens

Verification token support is provided by the `ActiveRecord::TokenFor#generate_token_for` method.
MinimalistAuthentication includes token definitions for **account_setup**, **password_reset**, and **email_verification**.

### Account Setup

The **account_setup** token is used for new users to set their initial password.
The token expires in 1 day and is invalidated when the user's password is changed.

#### Example

```ruby
token = user.generate_token_for(:account_setup)
User.find_by_token_for(:account_setup, token) # => user
user.update!(password: "new password")
User.find_by_token_for(:account_setup, token) # => nil
```

### Password Reset

The **password_reset** token is used for existing users to reset their password.
The token expires in 1 hour and is invalidated when the user's password is changed.

#### Example

```ruby
token = user.generate_token_for(:password_reset)
User.find_by_token_for(:password_reset, token) # => user
user.update!(password: "new password")
User.find_by_token_for(:password_reset, token) # => nil
```

### Email Verification

The **email_verification** token expires in 1 hour and is invalidated when the user's email is changed.

#### Example

```ruby
token = user.generate_token_for(:email_verification)
User.find_by_token_for(:email_verification, token) # => user
user.update!(email: "new_email@example.com")
User.find_by_token_for(:email_verification, token) # => nil
```

## Conversions

### Upgrading to Version 2.0

Pre 2.0 versions of MinimalistAuthentication supported multiple hash algorithms
and stored the hashed password and salt as separate fields in the database
(crypted_password and salt). The 2.0 version of MinimalistAuthentication
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

Version 3.0 of MinimalistAuthentication uses the Rails has_secure_password for authentication.
This change requires either renaming the **password_hash** column to **password_digest** or adding
an alias_attribute to map **password_digest** to **password_hash**.

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

### Upgrading to Version 3.2

The **verification_token** and **verification_token_generated_at** database columns are no longer used and can be safely removed from your user model.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
