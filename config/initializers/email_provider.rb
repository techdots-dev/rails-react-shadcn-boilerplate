return if Rails.env.test?

require Rails.root.join("app/services/email_delivery_method")


ActionMailer::Base.add_delivery_method(
  :email_provider,
  EmailDeliveryMethod,
  provider: Rails.application.config.email_provider
)

Rails.application.config.action_mailer.delivery_method = :email_provider
