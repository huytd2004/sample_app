class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [ :create, :destroy ]

  def create
    @micropost =
      current_user.microposts.build(micropost_params)

    if @micropost.save
      flash[:success] = I18n.t("app.micropost.created")
      redirect_to root_url
    else
      @feed_items =
        current_user.feed.paginate(page: params[:page])

      render "static_pages/home",
             status: :unprocessable_entity
    end
  end

  def destroy
    micropost =
      current_user.microposts.find_by(id: params[:id])

    micropost&.destroy

    flash[:success] = I18n.t("app.micropost.deleted")
    redirect_to request.referrer || root_url
  end

  private

  def micropost_params
    params.expect(micropost: [ :content, :image ])
  end
end
