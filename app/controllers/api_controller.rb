class ApiController < ActionController::API
  include ActionController::Cookies

  before_action :clear_current_tenant_context
  before_action :set_current_request_details
  before_action :authenticate

  private
    def authenticate
      session_record = if cookies.signed[:session_token].present?
        Tenanting.without_tenant { Session.find_signed(cookies.signed[:session_token]) }
      end

      if session_record
        Current.session = session_record
        Tenanting.set_current_tenant(session_record.user)
      else
        Tenanting.clear_current_tenant
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def render_user(user, status: :ok)
      render json: user.as_json(only: %i[ id email verified admin ]), status: status
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def clear_current_tenant_context
      Tenanting.clear_current_tenant
    end
end
