class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method

  validates :provider, :remote_payment_id, :status, presence: true
  validates :remote_payment_id, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }

  scope :newest_first, -> { order(created_at: :desc) }

  def as_api_json
    {
      id: id,
      payment_method_id: payment_method_id,
      status: status,
      amount: amount.to_s("F"),
      currency: currency,
      description: description,
      order_id: order_id,
      invoice_number: invoice_number,
      paid_at: paid_at&.iso8601,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }.compact
  end
end
