require "administrate/base_dashboard"

class SessionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    id: Field::Number,
    user_agent: Field::String,
    ip_address: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    user
    ip_address
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    user_agent
    ip_address
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    user
    user_agent
    ip_address
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(session)
    "Session ##{session.id}"
  end
end
