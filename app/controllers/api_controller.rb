class ApiController < ActionController::API
  include ActionController::Cookies

  before_action :set_current_request_details
  before_action :authenticate

  private
    def authenticate
      session_record = Session.find_signed(cookies.signed[:session_token]) if cookies.signed[:session_token].present?

      if session_record
        Current.session = session_record
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def render_user(user, status: :ok)
      render json: user.as_json(only: %i[ id email verified ]), status: status
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
end
