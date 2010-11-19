MinimalistAuthentication::Application.routes.draw do
  
  resource :session, :only => [:new, :create, :destroy]
  
end
