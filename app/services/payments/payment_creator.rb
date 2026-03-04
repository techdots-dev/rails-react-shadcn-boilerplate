module Payments
  class PaymentCreator
    def initialize(provider: PaymentProviders::Registry.build, provider_name: Rails.application.config.payment_provider)
      @provider = provider
      @provider_name = provider_name
    end

    def call(user:, attributes:)
      validate_attributes!(attributes)

      payment_method = user.payment_methods.find(attributes[:payment_method_id])
      amount = BigDecimal(attributes[:amount].to_s)
      remote_payment = @provider.create_payment(
        customer_id: payment_method.payment_customer_profile.remote_customer_id,
        payment_account_id: payment_method.remote_payment_account_id,
        amount:,
        description: attributes[:description],
        order_id: attributes[:order_id],
        invoice_number: attributes[:invoice_number]
      )

      user.payments.create!(
        payment_method:,
        provider: @provider_name,
        remote_payment_id: remote_payment.fetch(:remote_id),
        status: remote_payment[:status] || "submitted",
        amount: remote_payment[:amount] || amount,
        currency: "USD",
        description: attributes[:description],
        order_id: attributes[:order_id],
        invoice_number: attributes[:invoice_number],
        paid_at: remote_payment[:paid_at],
        remote_payload: remote_payment[:raw] || {}
      )
    end

    private
      def validate_attributes!(attributes)
        errors = {}
        errors[:payment_method_id] = [ "can't be blank" ] if attributes[:payment_method_id].blank?
        amount = parse_amount(attributes[:amount], errors)
        errors[:amount] = [ "must be greater than 0" ] if amount && !amount.positive?

        raise ValidationError.new(errors) if errors.present?
      end

      def parse_amount(raw_amount, errors)
        if raw_amount.blank?
          errors[:amount] = [ "can't be blank" ]
          return nil
        end

        BigDecimal(raw_amount.to_s)
      rescue ArgumentError
        errors[:amount] = [ "is not a number" ]
        nil
      end
  end
end
