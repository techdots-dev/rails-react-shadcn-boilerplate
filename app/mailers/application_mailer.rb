class ApplicationMailer < ActionMailer::Base
  default from: -> { Rails.application.config.email_default_from }
  layout "mailer"
end
