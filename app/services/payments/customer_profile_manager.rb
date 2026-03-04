module Payments
  class CustomerProfileManager
    def initialize(provider: PaymentProviders::Registry.build, provider_name: Rails.application.config.payment_provider)
      @provider = provider
      @provider_name = provider_name
    end

    def ensure_profile!(user:, attributes:)
      return user.payment_customer_profile if user.payment_customer_profile.present?

      customer_attributes = {
        first_name: attributes[:first_name],
        last_name: attributes[:last_name],
        email: attributes[:email].presence || user.email,
        phone: attributes[:phone],
        company: attributes[:company],
        billing_address: attributes[:billing_address] || {}
      }

      validate_customer_attributes!(customer_attributes)
      remote_customer = @provider.create_customer(customer: customer_attributes)

      user.create_payment_customer_profile!(
        provider: @provider_name,
        remote_customer_id: remote_customer.fetch(:remote_id),
        first_name: remote_customer[:first_name] || customer_attributes[:first_name],
        last_name: remote_customer[:last_name] || customer_attributes[:last_name],
        email: remote_customer[:email] || customer_attributes[:email],
        phone: remote_customer[:phone] || customer_attributes[:phone],
        company: remote_customer[:company] || customer_attributes[:company],
        billing_address: remote_customer[:billing_address] || customer_attributes[:billing_address],
        remote_payload: remote_customer[:raw] || {}
      )
    end

    private
      def validate_customer_attributes!(attributes)
        errors = {}
        errors[:first_name] = [ "can't be blank" ] if attributes[:first_name].blank?
        errors[:last_name] = [ "can't be blank" ] if attributes[:last_name].blank?
        errors[:email] = [ "can't be blank" ] if attributes[:email].blank?
        raise ValidationError.new(errors) if errors.present?
      end
  end
end
