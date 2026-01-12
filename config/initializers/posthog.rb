begin
require "posthog-ruby"
  PostHog.configure do |config|
    config.api_key = ENV["POSTHOG_API_KEY"]
    config.host = ENV.fetch("POSTHOG_API_HOST", "https://us.posthog.com")
  end
rescue LoadError
  Rails.logger.warn "PostHog gem not installed, skipping analytics"
end
