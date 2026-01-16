class SessionsController < ApiController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[ show destroy ]

  def index
    render json: Current.user.sessions.order(created_at: :desc)
  end

  def show
    render json: @session
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      @session = user.sessions.create!
      response.set_header "X-Session-Token", @session.signed_id
      cookies.signed[:session_token] = {
        value: @session.signed_id,
        httponly: true,
        same_site: :lax,
        secure: Rails.env.production?
      }

      render json: @session.as_json.merge(token: @session.signed_id), status: :created
      PostHog.capture({ distinct_id: user.id, event: "user_logged_in" }) if defined?(PostHog)
    else
      render json: { error: "That email or password is incorrect" }, status: :unauthorized
    end
  end

 def destroy
    @session.destroy
    cookies.delete(:session_token)
  end

  private
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
