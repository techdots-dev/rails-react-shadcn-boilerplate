module Admin
  class SessionsController < Admin::ApplicationController
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
      redirect_to "/login", notice: "Logged out successfully."
    end
  end
end
