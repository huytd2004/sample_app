class UsersController < ApplicationController
before_action :logged_in_user, only: [ :index, :edit, :update, :destroy ]
before_action :correct_user, only: [ :edit, :update ]
before_action :admin_user, only: :destroy

  def new
    @user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find_by(id: params[:id])
    unless @user
      flash[:danger] = t("app.user.danger")
      redirect_to root_path
    end
  end

  def create
    @user = User.new(user_params)
      if @user.save
        log_in @user
        flash[:success] = t("app.welcome")
        redirect_to @user
      else
        render :new, status: :unprocessable_entity
      end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = t("app.success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t("app.destroy.success")
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t("app.login.danger")
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
