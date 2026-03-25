module PaymentProviders
  class PaymentProvider
    def payment_options
      raise NotImplementedError, "Implement in provider adapter"
    end

    def create_customer(customer:)
      raise NotImplementedError, "Implement in provider adapter"
    end

    def create_payment_method(customer_id:, kind:, payment_details:, billing_details: {})
      raise NotImplementedError, "Implement in provider adapter"
    end

    def create_payment(customer_id:, payment_account_id:, amount:, description: nil, order_id: nil, invoice_number: nil)
      raise NotImplementedError, "Implement in provider adapter"
    end

    def create_subscription(customer_id:, payment_account_id:, amount:, start_date:, execution_frequency_type:, execution_frequency_parameter: nil, end_date: nil, description: nil, order_id: nil, invoice_number: nil)
      raise NotImplementedError, "Implement in provider adapter"
    end
  end
end
