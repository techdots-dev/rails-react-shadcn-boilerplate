module Admin
  class SessionsController < Admin::ApplicationController
    def destroy_current
      session_record = Session.find_signed(cookies.signed[:session_token]) if cookies.signed[:session_token].present?
      Current.session = session_record
      session_record&.destroy
      Current.session = nil
      cookies.delete(:session_token)
      redirect_to "/login", notice: "Logged out successfully."
    end
  end
end
