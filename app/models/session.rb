class Session < ApplicationRecord
  belongs_to :user
  acts_as_tenant(:user) if Rails.application.config.x.tenancy.enabled

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end
end
