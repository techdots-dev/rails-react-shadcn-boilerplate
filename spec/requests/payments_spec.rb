require "rails_helper"

RSpec.describe "Payments", type: :request do
  let!(:user) { create(:user, password: "passwordpassword", password_confirmation: "passwordpassword") }
  let(:provider) { instance_double(PaymentProviders::PaysimpleProvider) }

  before do
    allow(PaymentProviders::Registry).to receive(:build).and_return(provider)
  end

  describe "GET /payment_options" do
    it "returns the provider-backed payment options for the signed-in user" do
      allow(provider).to receive(:payment_options).and_return(
        "CreditCardsEnabled" => true,
        "AchEnabled" => true
      )

      get "/payment_options", headers: authenticated_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "provider" => "paysimple",
        "options" => {
          "CreditCardsEnabled" => true,
          "AchEnabled" => true
        }
      )
    end
  end

  describe "POST /payment_methods" do
    it "creates a customer profile and a stored credit card payment method" do
      allow(provider).to receive(:create_customer).and_return(
        remote_id: "customer-1",
        first_name: "Ada",
        last_name: "Lovelace",
        email: user.email,
        billing_address: { postal_code: "75001" },
        raw: { "Id" => "customer-1" }
      )
      allow(provider).to receive(:create_payment_method).and_return(
        remote_id: "account-1",
        kind: "credit_card",
        status: "Active",
        last4: "1111",
        card_brand: "Visa",
        expiration_month: 12,
        expiration_year: 2030,
        billing_zip: "75001",
        raw: { "Id" => "account-1" }
      )

      expect {
        post "/payment_methods", params: {
          kind: "credit_card",
          first_name: "Ada",
          last_name: "Lovelace",
          card_number: "4111111111111111",
          expiration_month: "12",
          expiration_year: "2030",
          cvv: "123",
          billing_address: {
            postal_code: "75001"
          }
        }, headers: authenticated_headers
      }.to change(PaymentMethod, :count).by(1)
        .and change(PaymentCustomerProfile, :count).by(1)

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body).to include(
        "kind" => "credit_card",
        "status" => "Active",
        "last4" => "1111",
        "card_brand" => "Visa",
        "default" => true
      )

      expect(user.reload.payment_customer_profile.remote_customer_id).to eq("customer-1")
      expect(user.payment_methods.first.remote_payment_account_id).to eq("account-1")
    end

    it "returns validation errors for incomplete payment method params" do
      post "/payment_methods", params: {
        kind: "credit_card",
        first_name: "Ada",
        last_name: "Lovelace"
      }, headers: authenticated_headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq(
        "errors" => {
          "card_number" => [ "can't be blank" ],
          "expiration_month" => [ "can't be blank" ],
          "expiration_year" => [ "can't be blank" ],
          "cvv" => [ "can't be blank" ]
        }
      )
    end
  end

  describe "POST /payments" do
    let!(:customer_profile) { create(:payment_customer_profile, user:) }
    let!(:payment_method) { create(:payment_method, user:, payment_customer_profile: customer_profile) }

    it "creates a one-time payment against a stored payment method" do
      allow(provider).to receive(:create_payment).and_return(
        remote_id: "payment-1",
        status: "Posted",
        amount: BigDecimal("49.99"),
        paid_at: Time.zone.parse("2026-03-04 10:30:00"),
        raw: { "Id" => "payment-1" }
      )

      expect {
        post "/payments", params: {
          payment_method_id: payment_method.id,
          amount: "49.99",
          description: "One-time onboarding fee",
          order_id: "ORD-1",
          invoice_number: "INV-1"
        }, headers: authenticated_headers
      }.to change(Payment, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include(
        "payment_method_id" => payment_method.id,
        "status" => "Posted",
        "amount" => "49.99",
        "description" => "One-time onboarding fee",
        "order_id" => "ORD-1",
        "invoice_number" => "INV-1"
      )
    end
  end

  describe "POST /subscriptions" do
    let!(:customer_profile) { create(:payment_customer_profile, user:) }
    let!(:payment_method) { create(:payment_method, user:, payment_customer_profile: customer_profile) }

    it "creates a recurring payment schedule" do
      allow(provider).to receive(:create_subscription).and_return(
        remote_id: "subscription-1",
        status: "Active",
        amount: BigDecimal("19.99"),
        start_date: Date.new(2026, 3, 15),
        end_date: Date.new(2026, 12, 15),
        next_payment_date: Date.new(2026, 4, 15),
        execution_frequency_type: "Monthly",
        execution_frequency_parameter: 15,
        raw: { "Id" => "subscription-1" }
      )

      expect {
        post "/subscriptions", params: {
          payment_method_id: payment_method.id,
          amount: "19.99",
          description: "Monthly support plan",
          start_date: "2026-03-15",
          end_date: "2026-12-15",
          execution_frequency_type: "Monthly",
          execution_frequency_parameter: 15
        }, headers: authenticated_headers
      }.to change(PaymentSubscription, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include(
        "payment_method_id" => payment_method.id,
        "status" => "Active",
        "amount" => "19.99",
        "description" => "Monthly support plan",
        "start_date" => "2026-03-15",
        "end_date" => "2026-12-15",
        "next_payment_date" => "2026-04-15",
        "execution_frequency_type" => "Monthly",
        "execution_frequency_parameter" => 15
      )
    end
  end

  def authenticated_headers
    post "/sign_in", params: { email: user.email, password: "passwordpassword" }
    { "Cookie" => response.headers["Set-Cookie"] }
  end
end
