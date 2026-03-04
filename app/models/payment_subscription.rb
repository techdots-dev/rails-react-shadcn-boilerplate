class PaymentSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method

  validates :provider, :remote_subscription_id, :status, :execution_frequency_type, presence: true
  validates :remote_subscription_id, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }
  validates :start_date, presence: true

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
      start_date: start_date&.iso8601,
      end_date: end_date&.iso8601,
      next_payment_date: next_payment_date&.iso8601,
      execution_frequency_type: execution_frequency_type,
      execution_frequency_parameter: execution_frequency_parameter,
      canceled_at: canceled_at&.iso8601,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }.compact
  end
end
