FactoryBot.define do
  factory :payment_method do
    association :user
    payment_customer_profile { association :payment_customer_profile, user: user }
    provider { "paysimple" }
    sequence(:remote_payment_account_id) { |n| "account-#{n}" }
    kind { "credit_card" }
    status { "active" }
    default { true }
    last4 { "1111" }
    card_brand { "Visa" }
    billing_zip { "75001" }
    expiration_month { 12 }
    expiration_year { 2030 }
    remote_payload { {} }
  end
end
