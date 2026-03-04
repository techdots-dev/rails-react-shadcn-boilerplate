# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_04_090300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "payment_customer_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "remote_customer_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "company"
    t.jsonb "billing_address", default: {}, null: false
    t.jsonb "remote_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["remote_customer_id"], name: "index_payment_customer_profiles_on_remote_customer_id", unique: true
    t.index ["user_id"], name: "index_payment_customer_profiles_on_user_id", unique: true
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "payment_customer_profile_id", null: false
    t.string "provider", null: false
    t.string "remote_payment_account_id", null: false
    t.string "kind", null: false
    t.string "status", default: "active", null: false
    t.boolean "default", default: false, null: false
    t.string "label"
    t.string "last4"
    t.string "card_brand"
    t.string "bank_name"
    t.string "account_holder_name"
    t.string "billing_zip"
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.jsonb "remote_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_customer_profile_id"], name: "index_payment_methods_on_payment_customer_profile_id"
    t.index ["remote_payment_account_id"], name: "index_payment_methods_on_remote_payment_account_id", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "payment_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "payment_method_id", null: false
    t.string "provider", null: false
    t.string "remote_subscription_id", null: false
    t.string "status", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "currency", default: "USD", null: false
    t.string "description"
    t.string "order_id"
    t.string "invoice_number"
    t.date "start_date", null: false
    t.date "end_date"
    t.date "next_payment_date"
    t.string "execution_frequency_type", null: false
    t.integer "execution_frequency_parameter"
    t.datetime "canceled_at"
    t.jsonb "remote_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id"], name: "index_payment_subscriptions_on_payment_method_id"
    t.index ["remote_subscription_id"], name: "index_payment_subscriptions_on_remote_subscription_id", unique: true
    t.index ["user_id"], name: "index_payment_subscriptions_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "payment_method_id", null: false
    t.string "provider", null: false
    t.string "remote_payment_id", null: false
    t.string "status", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "currency", default: "USD", null: false
    t.string "description"
    t.string "order_id"
    t.string "invoice_number"
    t.datetime "paid_at"
    t.text "error_message"
    t.jsonb "remote_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
    t.index ["remote_payment_id"], name: "index_payments_on_remote_payment_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "payment_customer_profiles", "users"
  add_foreign_key "payment_methods", "payment_customer_profiles"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payment_subscriptions", "payment_methods"
  add_foreign_key "payment_subscriptions", "users"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "payments", "users"
  add_foreign_key "sessions", "users"
end
