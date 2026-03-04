module PaymentProviders
  class Registry
    def self.build(name: Rails.application.config.payment_provider)
      case name.to_s
      when "paysimple"
        PaysimpleProvider.new
      else
        raise ArgumentError, "Unknown payment provider: #{name}"
      end
    end
  end
end
