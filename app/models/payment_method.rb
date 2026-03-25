class PaymentMethod < ApplicationRecord
  belongs_to :user
  belongs_to :payment_customer_profile

  has_many :payments
  has_many :payment_subscriptions

  enum :kind, { credit_card: "credit_card", ach: "ach" }, validate: true

  validates :provider, :remote_payment_account_id, :kind, :status, presence: true
  validates :remote_payment_account_id, uniqueness: true

  scope :newest_first, -> { order(created_at: :desc) }

  def as_api_json
    {
      id: id,
      kind: kind,
      status: status,
      default: default,
      label: label,
      last4: last4,
      card_brand: card_brand,
      bank_name: bank_name,
      account_holder_name: account_holder_name,
      billing_zip: billing_zip,
      expiration_month: expiration_month,
      expiration_year: expiration_year,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }.compact
  end
end
