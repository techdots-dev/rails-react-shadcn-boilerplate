# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'factory_bot_rails'

FactoryBot.reload

users_to_create = 50 - User.count
FactoryBot.create_list(:user, users_to_create) if users_to_create.positive?

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "passwordpassword")

admin_user = User.find_or_initialize_by(email: admin_email)
admin_user.password = admin_password if admin_user.new_record?
admin_user.password_confirmation = admin_password if admin_user.new_record?
admin_user.verified = true
admin_user.admin = true
admin_user.save!
