class PasswordResetsController < ApplicationController
  before_action :get_user, only: [ :edit, :update ]
  before_action :valid_user, only: [ :edit, :update ]
  before_action :check_expiration, only: [ :edit, :update ]

  def create
    user = User.find_by(email: params[:password_reset][:email].downcase)

    if user
      user.create_reset_digest
      user.send_password_reset_email
      flash[:info] = I18n.t("app.password_reset.email_sent")
      redirect_to root_url
    else
      flash.now[:danger] = I18n.t("app.password_reset.email_not_found")
      render :new, status: :unprocessable_entity
    end
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = I18n.t("app.password_reset.expired")
    redirect_to new_password_reset_url
  end

  def user_params
    params.require(:user).permit(
      :password,
      :password_confirmation
    )
  end
  def update
    if params[:user][:password].blank?
      @user.errors.add(:password, I18n.t("app.password_reset.password_empty"))
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      @user.update_column(:reset_digest, nil)
      log_in @user
      flash[:success] = I18n.t("app.password_reset.success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
