# Rails.application.config.to_prepare do
#   Spina::Admin::SessionsController.class_eval do
#     skip_before_action :verify_authenticity_token, only: :create
#   end
# end
Rails.application.config.session_store :cookie_store,
  key: '_rails_react_shadcn_boilerplate_session',
  same_site: :lax,
  path: '/'
