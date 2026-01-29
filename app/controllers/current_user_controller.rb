class CurrentUserController < ApiController
  def show
    render_user(Current.user)
  end
end
