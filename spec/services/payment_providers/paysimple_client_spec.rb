require "rails_helper"

RSpec.describe PaymentProviders::PaysimpleClient do
  let(:http) { class_double(Net::HTTP) }
  let(:connection) { instance_double("Net::HTTP") }
  let(:client) do
    described_class.new(
      username: "merchant",
      api_key: "secret-key",
      base_url: "https://api.paysimple.com",
      http:
    )
  end

  describe "#post" do
    it "sends the PaySimple authorization format and API version path" do
      response = instance_double(Net::HTTPResponse, code: "201", body: { Id: 99 }.to_json)
      captured_request = nil

      allow(http).to receive(:start).with("api.paysimple.com", 443, use_ssl: true).and_yield(connection)
      allow(connection).to receive(:request) do |request|
        captured_request = request
        response
      end

      client.post("/customer", { FirstName: "Ada" })

      expect(captured_request["Authorization"]).to eq("basic merchant:secret-key")
      expect(captured_request["Content-Type"]).to eq("application/json")
      expect(captured_request.path).to eq("/v4/customer")
      expect(JSON.parse(captured_request.body)).to eq("FirstName" => "Ada")
    end

    it "raises a provider error with parsed details on non-success responses" do
      response = instance_double(
        Net::HTTPResponse,
        code: "422",
        body: {
          Meta: {
            Errors: [
              { Message: "Amount must be greater than zero" }
            ]
          }
        }.to_json
      )

      allow(http).to receive(:start).and_yield(connection)
      allow(connection).to receive(:request).and_return(response)

      expect {
        client.post("/payment", { Amount: "0.00" })
      }.to raise_error(PaymentProviders::Error) do |error|
        expect(error.status).to eq(422)
        expect(error.message).to eq("Amount must be greater than zero")
        expect(error.details).to eq([{ "Message" => "Amount must be greater than zero" }])
      end
    end
  end
end
