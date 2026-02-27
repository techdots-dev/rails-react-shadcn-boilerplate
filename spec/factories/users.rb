FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@techdots.dev" }
    password { "!Supersecretpassword101" }
    verified { true }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
