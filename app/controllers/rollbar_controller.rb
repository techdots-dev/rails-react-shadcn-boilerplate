class RollbarController < ActionController::API
  def show
    token = rollbar_client_access_token

    render json: {
      enabled: token.present?,
      access_token: token,
      environment: rollbar_environment,
      code_version: rollbar_code_version
    }.compact
  end

  private
    def rollbar_client_access_token
      Rails.application.credentials.dig(:rollbar, :client_access_token) ||
        ENV["ROLLBAR_CLIENT_ACCESS_TOKEN"]
    end

    def rollbar_environment
      Rails.application.credentials.dig(:rollbar, :environment) ||
        ENV["ROLLBAR_ENVIRONMENT"] ||
        Rails.env
    end

    def rollbar_code_version
      Rails.application.credentials.dig(:rollbar, :code_version) ||
        ENV["ROLLBAR_CODE_VERSION"]
    end
end
