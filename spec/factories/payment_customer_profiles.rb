FactoryBot.define do
  factory :payment_customer_profile do
    association :user
    provider { "paysimple" }
    sequence(:remote_customer_id) { |n| "customer-#{n}" }
    first_name { "Ada" }
    last_name { "Lovelace" }
    sequence(:email) { |n| "customer#{n}@techdots.dev" }
    billing_address { { postal_code: "75001" } }
    remote_payload { {} }
  end
end
