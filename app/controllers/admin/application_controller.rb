module Admin
  class ApplicationController < Administrate::ApplicationController
    layout "admin"
    before_action :authenticate_admin!

    private
      def authenticate_admin!
        return if current_admin_user&.admin?

        redirect_to root_path, alert: "You are not authorized to access this page."
      end

      def current_admin_user
        return @current_admin_user if defined?(@current_admin_user)

        session_record = if cookies.signed[:session_token].present?
          Tenanting.without_tenant { Session.find_signed(cookies.signed[:session_token]) }
        end
        Tenanting.set_current_tenant(session_record&.user)
        @current_admin_user = session_record&.user
      end
  end
end
