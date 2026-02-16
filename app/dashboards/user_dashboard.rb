require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    sessions: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    verified: Field::Boolean,
    admin: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    email
    verified
    admin
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    verified
    admin
    sessions
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    email
    verified
    admin
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(user)
    user.email
  end
end
