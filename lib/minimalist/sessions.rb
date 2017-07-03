module Minimalist
  module Sessions

    def new
      @user = User.new
    end

    def create
      if user = User.authenticate(user_params[:email], user_params[:password])
        user.logged_in
        session[:user_id] = user.id
        after_authentication(user)
        redirect_back_or_default(login_redirect_to(user))
        return
      else
        after_authentication_failure
        flash.now[:alert] = "Couldn't log you in as '#{user_params[:email]}'"
        render action: 'new'
      end
    end

    def destroy
      session[:user_id] = nil
      flash[:notice] = "You have been logged out."
      redirect_to logout_redirect_to
    end


    private
    
    def user_params
      @user_params ||= params.require(:user).permit(:email, :password)
    end

    def login_redirect_to(user)
      '/'
    end

    def logout_redirect_to
      '/'
    end

    def after_authentication(user)
      # overide in application
    end

    def after_authentication_failure
      # overide in application
    end
  end
end
