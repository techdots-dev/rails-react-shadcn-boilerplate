class CreatePaymentSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :remote_subscription_id, null: false
      t.string :status, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: "USD"
      t.string :description
      t.string :order_id
      t.string :invoice_number
      t.date :start_date, null: false
      t.date :end_date
      t.date :next_payment_date
      t.string :execution_frequency_type, null: false
      t.integer :execution_frequency_parameter
      t.datetime :canceled_at
      t.jsonb :remote_payload, null: false, default: {}

      t.timestamps
    end

    add_index :payment_subscriptions, :remote_subscription_id, unique: true
  end
end
