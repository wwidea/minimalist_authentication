class SessionsController < ApplicationController
  include Minimalist::Sessions
  skip_before_action :authorization_required, only: %i(new create)
end
