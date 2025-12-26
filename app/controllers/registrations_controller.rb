class RegistrationsController < ApiController
  skip_before_action :authenticate

  def create
    @user = User.new(user_params)

    if @user.save
      send_email_verification
      render json: @user, status: :created
      PostHog.capture({ distinct_id: @user.id, event: "user_signed_up" }) if defined?(PostHog)
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  private
    def user_params
      params.permit(:email, :password, :password_confirmation)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
