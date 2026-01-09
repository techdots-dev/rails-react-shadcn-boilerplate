module EmailProviders
  class Registry
    def self.build(name: Rails.application.config.email_provider)
      provider_name = name.to_s

      case provider_name
      when "sendgrid"
        SendgridProvider.new(api_key: Rails.application.config.sendgrid_api_key)
      else
        raise ArgumentError, "Unknown email provider: #{provider_name}"
      end
    end
  end
end
