class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  include Minimalist::Authorization
  
  # Lock down everything by default
  # use skip_before_action to open up specific actions
  before_action :authorization_required
end
