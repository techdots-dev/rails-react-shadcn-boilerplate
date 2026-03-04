require "rails_helper"

RSpec.describe PaymentProviders::PaysimpleProvider do
  let(:client) { instance_double(PaymentProviders::PaysimpleClient) }
  let(:provider) { described_class.new(client:) }

  describe "#create_payment_method" do
    it "normalizes a credit card payment account" do
      allow(client).to receive(:post).with(
        "/paymentaccount/creditcard",
        hash_including(
          CustomerId: "customer-1",
          CreditCardNumber: "4111111111111111",
          ExpirationDate: "12/2030",
          Cvv: "123",
          BillingZipCode: "75001"
        )
      ).and_return(
        "Id" => 17,
        "LastFour" => "1111",
        "Issuer" => "Visa",
        "ExpirationDate" => "12/2030",
        "Status" => "Active",
        "BillingZipCode" => "75001"
      )

      result = provider.create_payment_method(
        customer_id: "customer-1",
        kind: :credit_card,
        payment_details: {
          number: "4111111111111111",
          expiration_month: "12",
          expiration_year: "2030",
          cvv: "123"
        },
        billing_details: { postal_code: "75001" }
      )

      expect(result).to include(
        remote_id: "17",
        kind: "credit_card",
        status: "Active",
        last4: "1111",
        card_brand: "Visa",
        expiration_month: 12,
        expiration_year: 2030,
        billing_zip: "75001"
      )
    end
  end

  describe "#create_subscription" do
    it "normalizes recurring payment schedule data" do
      allow(client).to receive(:post).with(
        "/recurringpaymentschedule",
        hash_including(
          CustomerId: "customer-1",
          PaymentAccountId: "account-1",
          Amount: "29.99",
          StartDate: "2026-03-10",
          ExecutionFrequencyType: "Monthly",
          ExecutionFrequencyParameter: 10
        )
      ).and_return(
        "Id" => 88,
        "Status" => "Active",
        "Amount" => "29.99",
        "StartDate" => "2026-03-10",
        "EndDate" => "2026-12-10",
        "NextPaymentDate" => "2026-04-10",
        "ExecutionFrequencyType" => "Monthly",
        "ExecutionFrequencyParameter" => 10
      )

      result = provider.create_subscription(
        customer_id: "customer-1",
        payment_account_id: "account-1",
        amount: BigDecimal("29.99"),
        start_date: Date.new(2026, 3, 10),
        end_date: Date.new(2026, 12, 10),
        execution_frequency_type: "Monthly",
        execution_frequency_parameter: 10
      )

      expect(result).to include(
        remote_id: "88",
        status: "Active",
        amount: BigDecimal("29.99"),
        start_date: Date.new(2026, 3, 10),
        end_date: Date.new(2026, 12, 10),
        next_payment_date: Date.new(2026, 4, 10),
        execution_frequency_type: "Monthly",
        execution_frequency_parameter: 10
      )
    end
  end
end
