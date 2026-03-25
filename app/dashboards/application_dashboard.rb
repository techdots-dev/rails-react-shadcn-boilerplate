require "administrate/base_dashboard"

class ApplicationDashboard < Administrate::BaseDashboard
  def self.display_resource(resource)
    resource.to_s
  end
end
