class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payment_customer_profile, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :remote_payment_account_id, null: false
      t.string :kind, null: false
      t.string :status, null: false, default: "active"
      t.boolean :default, null: false, default: false
      t.string :label
      t.string :last4
      t.string :card_brand
      t.string :bank_name
      t.string :account_holder_name
      t.string :billing_zip
      t.integer :expiration_month
      t.integer :expiration_year
      t.jsonb :remote_payload, null: false, default: {}

      t.timestamps
    end

    add_index :payment_methods, :remote_payment_account_id, unique: true
  end
end
