class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :remote_payment_id, null: false
      t.string :status, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: "USD"
      t.string :description
      t.string :order_id
      t.string :invoice_number
      t.datetime :paid_at
      t.text :error_message
      t.jsonb :remote_payload, null: false, default: {}

      t.timestamps
    end

    add_index :payments, :remote_payment_id, unique: true
  end
end
