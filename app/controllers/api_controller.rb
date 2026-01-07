class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::Cookies

  before_action :set_current_request_details
  before_action :authenticate

  private
    def authenticate
      session_record = authenticate_with_http_token { |token, _| Session.find_signed(token) }
      session_record ||= Session.find_signed(cookies.signed[:session_token]) if cookies.signed[:session_token].present?

      if session_record
        Current.session = session_record
      else
        request_http_token_authentication
      end
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
end