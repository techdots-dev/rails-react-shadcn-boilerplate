require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "action_mailbox/engine"
require "action_text/engine"
require "active_storage/engine"
require "propshaft"
require "propshaft/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.action_dispatch.cookies_same_site_protection = :lax

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Serve the full Rails stack so we can render the React frontend alongside the API.
    config.api_only = false

    config.autoload_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("app/services")

    config.email_provider = ENV.fetch("EMAIL_PROVIDER", "sendgrid")
    config.email_default_from = ENV.fetch("EMAIL_DEFAULT_FROM", "from@example.com")
    config.sendgrid_api_key = ENV["SENDGRID_API_KEY"]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [ :en ]
  end
end
