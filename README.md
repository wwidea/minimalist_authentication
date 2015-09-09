[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/wwidea/minimalist_authentication)

MinimalistAuthentication
========================

A Rails authentication gem that takes a minimalist approach. It is designed to be simple to understand, use, and modify for your application.

This gem was largely inspired by the restful-authentication plugin (http://github.com/technoweenie/restful-authentication/tree/master). I selected the essential methods for password based authentication, reorganized them, trimmed them down when possible, added a couple of features, and resisted the urge to start adding more.


Installation
============
1) Add to your Gemfile:

    gem 'minimalist_authentication'

2) Create a user model:

    bin/rails generate model user active:boolean email:string crypted_password:string salt:string using_digest_version:integer last_logged_in_at:datetime


Example
=======

1) app/models/user.rb

    class User < ActiveRecord::Base
      include Minimalist::Authentication
    end

2) app/controllers/application.rb

    class ApplicationController < ActionController::Base
      include Minimalist::Authorization
      
      # Lock down everything by default
      # use skip_before_filter to open up sepecific actions
      prepend_before_filter :authorization_required
    end

3) app/controllers/sessions_controller.rb

    class SessionsController < ApplicationController
      include Minimalist::Sessions
      skip_before_filter :authorization_required, only: [:new, :create]
    end

4) test/test_helper.rb

    class ActiveSupport::TestCase
      include Minimalist::TestHelper
    end


Copyright (c) 2009 Aaron Baldwin, released under the MIT license
