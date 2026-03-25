module Payments
  class SubscriptionCreator
    def initialize(provider: PaymentProviders::Registry.build, provider_name: Rails.application.config.payment_provider)
      @provider = provider
      @provider_name = provider_name
    end

    def call(user:, attributes:)
      validate_attributes!(attributes)

      payment_method = user.payment_methods.find(attributes[:payment_method_id])
      amount = BigDecimal(attributes[:amount].to_s)
      start_date = Date.iso8601(attributes[:start_date].to_s)
      end_date = attributes[:end_date].present? ? Date.iso8601(attributes[:end_date].to_s) : nil

      remote_subscription = @provider.create_subscription(
        customer_id: payment_method.payment_customer_profile.remote_customer_id,
        payment_account_id: payment_method.remote_payment_account_id,
        amount:,
        start_date:,
        end_date:,
        execution_frequency_type: attributes[:execution_frequency_type],
        execution_frequency_parameter: attributes[:execution_frequency_parameter],
        description: attributes[:description],
        order_id: attributes[:order_id],
        invoice_number: attributes[:invoice_number]
      )

      user.payment_subscriptions.create!(
        payment_method:,
        provider: @provider_name,
        remote_subscription_id: remote_subscription.fetch(:remote_id),
        status: remote_subscription[:status] || "active",
        amount: remote_subscription[:amount] || amount,
        currency: "USD",
        description: attributes[:description],
        order_id: attributes[:order_id],
        invoice_number: attributes[:invoice_number],
        start_date: remote_subscription[:start_date] || start_date,
        end_date: remote_subscription[:end_date] || end_date,
        next_payment_date: remote_subscription[:next_payment_date],
        execution_frequency_type: remote_subscription[:execution_frequency_type] || attributes[:execution_frequency_type],
        execution_frequency_parameter: remote_subscription[:execution_frequency_parameter] || attributes[:execution_frequency_parameter],
        remote_payload: remote_subscription[:raw] || {}
      )
    end

    private
      def validate_attributes!(attributes)
        errors = {}
        errors[:payment_method_id] = [ "can't be blank" ] if attributes[:payment_method_id].blank?
        errors[:execution_frequency_type] = [ "can't be blank" ] if attributes[:execution_frequency_type].blank?
        validate_amount!(attributes[:amount], errors)
        validate_date!(:start_date, attributes[:start_date], errors)
        validate_date!(:end_date, attributes[:end_date], errors) if attributes[:end_date].present?

        raise ValidationError.new(errors) if errors.present?
      end

      def validate_amount!(raw_amount, errors)
        if raw_amount.blank?
          errors[:amount] = [ "can't be blank" ]
          return
        end

        amount = BigDecimal(raw_amount.to_s)
        errors[:amount] = [ "must be greater than 0" ] unless amount.positive?
      rescue ArgumentError
        errors[:amount] = [ "is not a number" ]
      end

      def validate_date!(field, raw_value, errors)
        if raw_value.blank?
          errors[field] = [ "can't be blank" ] if field == :start_date
          return
        end

        Date.iso8601(raw_value.to_s)
      rescue ArgumentError
        errors[field] = [ "is invalid" ]
      end
  end
end
