module Tenanting
  module_function

  def enabled?
    Rails.application.config.x.tenancy.enabled
  end

  def set_current_tenant(tenant)
    return unless enabled? && defined?(ActsAsTenant)

    ActsAsTenant.current_tenant = tenant
  end

  def clear_current_tenant
    return unless enabled? && defined?(ActsAsTenant)

    ActsAsTenant.current_tenant = nil
  end

  def without_tenant
    return yield unless enabled? && defined?(ActsAsTenant)

    ActsAsTenant.without_tenant { yield }
  end
end

if defined?(ActsAsTenant)
  ActsAsTenant.configure do |config|
    config.require_tenant = if Rails.application.config.x.tenancy.require_tenant
      -> { Tenanting.enabled? }
    else
      false
    end
  end
end
