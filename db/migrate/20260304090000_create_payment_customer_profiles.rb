class CreatePaymentCustomerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_customer_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :provider, null: false
      t.string :remote_customer_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company
      t.jsonb :billing_address, null: false, default: {}
      t.jsonb :remote_payload, null: false, default: {}

      t.timestamps
    end

    add_index :payment_customer_profiles, :remote_customer_id, unique: true
  end
end
