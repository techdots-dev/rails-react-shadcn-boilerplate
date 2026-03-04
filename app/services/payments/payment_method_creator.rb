module Payments
  class PaymentMethodCreator
    def initialize(provider: PaymentProviders::Registry.build, provider_name: Rails.application.config.payment_provider)
      @provider = provider
      @provider_name = provider_name
      @customer_profile_manager = CustomerProfileManager.new(provider:, provider_name:)
      @boolean_type = ActiveModel::Type::Boolean.new
    end

    def call(user:, attributes:)
      kind = attributes[:kind].to_s
      validate_attributes!(kind:, attributes:)

      customer_profile = @customer_profile_manager.ensure_profile!(user:, attributes: customer_attributes(attributes))
      remote_payment_method = @provider.create_payment_method(
        customer_id: customer_profile.remote_customer_id,
        kind:,
        payment_details: payment_details(kind:, attributes:),
        billing_details: billing_details(attributes)
      )

      persist_payment_method!(
        user:,
        customer_profile:,
        kind:,
        attributes:,
        remote_payment_method:
      )
    end

    private
      def persist_payment_method!(user:, customer_profile:, kind:, attributes:, remote_payment_method:)
        make_default = user.payment_methods.none? || @boolean_type.cast(attributes[:default])

        ActiveRecord::Base.transaction do
          user.payment_methods.update_all(default: false) if make_default

          user.payment_methods.create!(
            payment_customer_profile: customer_profile,
            provider: @provider_name,
            remote_payment_account_id: remote_payment_method.fetch(:remote_id),
            kind: remote_payment_method[:kind] || kind,
            status: remote_payment_method[:status] || "active",
            default: make_default,
            label: attributes[:label].presence || remote_payment_method[:label],
            last4: remote_payment_method[:last4],
            card_brand: remote_payment_method[:card_brand],
            bank_name: remote_payment_method[:bank_name],
            account_holder_name: remote_payment_method[:account_holder_name] || attributes[:account_holder_name],
            billing_zip: remote_payment_method[:billing_zip] || billing_details(attributes)[:postal_code],
            expiration_month: remote_payment_method[:expiration_month],
            expiration_year: remote_payment_method[:expiration_year],
            remote_payload: remote_payment_method[:raw] || {}
          )
        end
      end

      def validate_attributes!(kind:, attributes:)
        errors = {}

        errors[:kind] = [ "must be credit_card or ach" ] unless %w[ credit_card ach ].include?(kind)

        if kind == "credit_card"
          errors[:card_number] = [ "can't be blank" ] if attributes[:card_number].blank?
          errors[:expiration_month] = [ "can't be blank" ] if attributes[:expiration_month].blank?
          errors[:expiration_year] = [ "can't be blank" ] if attributes[:expiration_year].blank?
          errors[:cvv] = [ "can't be blank" ] if attributes[:cvv].blank?
        end

        if kind == "ach"
          errors[:account_number] = [ "can't be blank" ] if attributes[:account_number].blank?
          errors[:routing_number] = [ "can't be blank" ] if attributes[:routing_number].blank?
          errors[:account_holder_name] = [ "can't be blank" ] if attributes[:account_holder_name].blank?
        end

        raise ValidationError.new(errors) if errors.present?
      end

      def customer_attributes(attributes)
        {
          first_name: attributes[:first_name],
          last_name: attributes[:last_name],
          email: attributes[:email],
          phone: attributes[:phone],
          company: attributes[:company],
          billing_address: billing_details(attributes)
        }
      end

      def payment_details(kind:, attributes:)
        if kind == "credit_card"
          {
            number: attributes[:card_number],
            expiration_month: attributes[:expiration_month],
            expiration_year: attributes[:expiration_year],
            cvv: attributes[:cvv]
          }
        else
          {
            account_number: attributes[:account_number],
            routing_number: attributes[:routing_number],
            account_holder_name: attributes[:account_holder_name],
            account_type: attributes[:account_type],
            bank_name: attributes[:bank_name]
          }
        end
      end

      def billing_details(attributes)
        {
          street_address1: attributes.dig(:billing_address, :street_address1),
          street_address2: attributes.dig(:billing_address, :street_address2),
          city: attributes.dig(:billing_address, :city),
          state: attributes.dig(:billing_address, :state),
          postal_code: attributes[:billing_zip].presence || attributes.dig(:billing_address, :postal_code),
          country: attributes.dig(:billing_address, :country)
        }.compact
      end
  end
end
