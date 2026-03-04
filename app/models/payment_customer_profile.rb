class PaymentCustomerProfile < ApplicationRecord
  belongs_to :user

  has_many :payment_methods

  validates :provider, :remote_customer_id, :first_name, :last_name, :email, presence: true
  validates :remote_customer_id, uniqueness: true
  validates :user_id, uniqueness: true

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }
end
