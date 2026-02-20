Rollbar.configure do |config|
  config.access_token = Rails.application.credentials.dig(:rollbar, :server_access_token) ||
    ENV["ROLLBAR_SERVER_ACCESS_TOKEN"]

  config.environment = Rails.application.credentials.dig(:rollbar, :environment) ||
    ENV["ROLLBAR_ENVIRONMENT"] ||
    Rails.env

  config.enabled = config.access_token.present?
end
