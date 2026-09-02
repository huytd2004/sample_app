class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user&.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == "1" ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || user
      else
        flash[:warning] = I18n.t("app.auth.warning")
        redirect_to root_url
      end
    else
      flash.now[:danger] = I18n.t("app.auth.danger")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
