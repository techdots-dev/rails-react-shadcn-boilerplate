module PaymentProviders
  class PaysimpleProvider < PaymentProvider
    def initialize(client: default_client)
      @client = client
    end

    def payment_options
      client.get("/merchant/paymentoptions")
    end

    def create_customer(customer:)
      response = client.post("/customer", customer_payload(customer))

      {
        remote_id: response.fetch("Id").to_s,
        first_name: response["FirstName"] || customer[:first_name],
        last_name: response["LastName"] || customer[:last_name],
        email: response["Email"] || customer[:email],
        phone: response["Phone"] || customer[:phone],
        company: response["Company"] || customer[:company],
        billing_address: normalize_address(response["BillingAddress"]) || customer[:billing_address] || {},
        raw: response
      }
    end

    def create_payment_method(customer_id:, kind:, payment_details:, billing_details: {})
      response = client.post(payment_account_path_for(kind), payment_method_payload(customer_id:, kind:, payment_details:, billing_details:))
      expiration_month, expiration_year = parse_expiration(response["ExpirationDate"])

      {
        remote_id: response.fetch("Id").to_s,
        kind: kind.to_s,
        status: response["Status"] || (response["IsActive"] == false ? "inactive" : "active"),
        label: response["Nickname"] || response["Issuer"] || response["BankName"],
        last4: response["LastFour"] || response["AccountNumber"]&.to_s&.last(4),
        card_brand: response["Issuer"] || response["CreditCardType"],
        bank_name: response["BankName"],
        account_holder_name: response["AccountHolderName"] || payment_details[:account_holder_name],
        billing_zip: response["BillingZipCode"] || billing_details[:postal_code],
        expiration_month: expiration_month,
        expiration_year: expiration_year,
        raw: response
      }
    end

    def create_payment(customer_id:, payment_account_id:, amount:, description: nil, order_id: nil, invoice_number: nil)
      response = client.post("/payment", {
        CustomerId: customer_id,
        PaymentAccountId: payment_account_id,
        Amount: format_amount(amount),
        Description: description,
        OrderId: order_id,
        InvoiceNumber: invoice_number
      }.compact)

      {
        remote_id: response.fetch("Id").to_s,
        status: response["Status"] || "submitted",
        amount: decimal_amount(response["Amount"] || amount),
        paid_at: parse_time(response["PaymentDate"] || response["SettledDate"] || response["CreatedOn"]),
        raw: response
      }
    end

    def create_subscription(customer_id:, payment_account_id:, amount:, start_date:, execution_frequency_type:, execution_frequency_parameter: nil, end_date: nil, description: nil, order_id: nil, invoice_number: nil)
      response = client.post("/recurringpaymentschedule", {
        CustomerId: customer_id,
        PaymentAccountId: payment_account_id,
        Amount: format_amount(amount),
        StartDate: format_date(start_date),
        EndDate: format_date(end_date),
        ExecutionFrequencyType: execution_frequency_type,
        ExecutionFrequencyParameter: execution_frequency_parameter,
        Description: description,
        OrderId: order_id,
        InvoiceNumber: invoice_number
      }.compact)

      {
        remote_id: response.fetch("Id").to_s,
        status: response["Status"] || "active",
        amount: decimal_amount(response["Amount"] || amount),
        start_date: parse_date(response["StartDate"] || start_date),
        end_date: parse_date(response["EndDate"] || end_date),
        execution_frequency_type: response["ExecutionFrequencyType"] || execution_frequency_type,
        execution_frequency_parameter: response["ExecutionFrequencyParameter"] || execution_frequency_parameter,
        next_payment_date: parse_date(response["NextPaymentDate"]),
        raw: response
      }
    end

    private
      attr_reader :client

      def default_client
        PaysimpleClient.new(
          username: Rails.application.config.paysimple_username,
          api_key: Rails.application.config.paysimple_api_key,
          base_url: Rails.application.config.paysimple_base_url
        )
      end

      def customer_payload(customer)
        {
          FirstName: customer[:first_name],
          LastName: customer[:last_name],
          Email: customer[:email],
          Phone: customer[:phone],
          Company: customer[:company],
          BillingAddress: address_payload(customer[:billing_address])
        }.compact
      end

      def payment_account_path_for(kind)
        case kind.to_s
        when "credit_card"
          "/paymentaccount/creditcard"
        when "ach"
          "/paymentaccount/ach"
        else
          raise ArgumentError, "Unsupported payment method kind: #{kind}"
        end
      end

      def payment_method_payload(customer_id:, kind:, payment_details:, billing_details:)
        base_payload = {
          CustomerId: customer_id,
          BillingZipCode: billing_details[:postal_code]
        }

        case kind.to_s
        when "credit_card"
          base_payload.merge(
            CreditCardNumber: payment_details[:number],
            ExpirationDate: format_expiration(payment_details[:expiration_month], payment_details[:expiration_year]),
            Cvv: payment_details[:cvv]
          ).compact
        when "ach"
          base_payload.merge(
            AccountNumber: payment_details[:account_number],
            RoutingNumber: payment_details[:routing_number],
            AccountHolderName: payment_details[:account_holder_name],
            BankName: payment_details[:bank_name],
            IsCheckingAccount: payment_details[:account_type].to_s != "savings"
          ).compact
        else
          raise ArgumentError, "Unsupported payment method kind: #{kind}"
        end
      end

      def address_payload(address)
        return if address.blank?

        {
          StreetAddress1: address[:street_address1],
          StreetAddress2: address[:street_address2],
          City: address[:city],
          State: address[:state],
          Zip: address[:postal_code],
          Country: address[:country]
        }.compact
      end

      def normalize_address(address)
        return if address.blank?

        {
          street_address1: address["StreetAddress1"] || address[:StreetAddress1],
          street_address2: address["StreetAddress2"] || address[:StreetAddress2],
          city: address["City"] || address[:City],
          state: address["State"] || address[:State],
          postal_code: address["Zip"] || address[:Zip],
          country: address["Country"] || address[:Country]
        }.compact
      end

      def format_amount(amount)
        decimal_amount(amount).to_s("F")
      end

      def decimal_amount(amount)
        BigDecimal(amount.to_s)
      end

      def format_date(value)
        parse_date(value)&.iso8601
      end

      def parse_date(value)
        return if value.blank?
        return value if value.is_a?(Date)

        Date.iso8601(value.to_s)
      rescue ArgumentError
        nil
      end

      def parse_time(value)
        return if value.blank?
        return value if value.is_a?(Time)

        Time.zone.parse(value.to_s)
      end

      def format_expiration(month, year)
        format("%02d/%s", month.to_i, year.to_s)
      end

      def parse_expiration(value)
        return [ nil, nil ] if value.blank?

        match = value.to_s.match(/\A(?<month>\d{1,2})\/(?<year>\d{2,4})\z/)
        return [ match[:month].to_i, match[:year].to_i ] if match

        date_match = value.to_s.match(/\A(?<year>\d{4})-(?<month>\d{2})/)
        return [ date_match[:month].to_i, date_match[:year].to_i ] if date_match

        [ nil, nil ]
      end
  end
end
