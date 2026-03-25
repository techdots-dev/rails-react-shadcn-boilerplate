class SessionsController < ApiController
  skip_before_action :authenticate, only: %i[ create destroy_current ]

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
      response.set_header("X-Session-Token", @session.signed_id)
      cookies.signed[:session_token] = {
        value: @session.signed_id,
        httponly: true,
        same_site: :lax,
        secure: Rails.env.production?
      }

      render_user(user, status: :created)
      PostHog.capture({ distinct_id: user.id, event: "user_logged_in" }) if defined?(PostHog)
    else
      render json: { error: "That email or password is incorrect" }, status: :unauthorized
    end
  end

  def destroy
    return unless @session

    @session.destroy
    if @session == Current.session
      Current.session = nil
      cookies.delete(:session_token)
    end
    head :no_content
  end

  def destroy_current
    session_record = if cookies.signed[:session_token].present?
      Tenanting.without_tenant { Session.find_signed(cookies.signed[:session_token]) }
    end
    Current.session = session_record
    Tenanting.set_current_tenant(session_record&.user)
    session_record&.destroy
    Current.session = nil
    Tenanting.clear_current_tenant
    cookies.delete(:session_token)
    head :no_content
  end

  private
    def set_session
      @session = Current.user.sessions.find_by(id: params[:id])
      return if @session

      render json: { error: "Session not found" }, status: :not_found
    end
end
