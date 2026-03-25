require_relative "production"

Rails.application.configure do
  # Keep staging-specific hostnames and toggles configurable.
  config.hosts.clear
end
