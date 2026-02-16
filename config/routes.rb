Rails.application.routes.draw do
  namespace :admin do
    root to: "users#index"
    resources :sessions
    resources :users
  end

  defaults format: :json do
    post "sign_in", to: "sessions#create"
    post "sign_up", to: "registrations#create"
    delete "sign_out", to: "sessions#destroy_current"
    get "current_user", to: "current_user#show"
    get "rollbar", to: "rollbar#show"
    resources :sessions, only: [ :index, :show, :destroy ]
    resource  :password, only: [ :edit, :update ]

    namespace :identity do
      resource :email,              only: [ :edit, :update ]
      resource :email_verification, only: [ :show, :create ]
      resource :password_reset,     only: [ :new, :edit, :create, :update ]
    end
  end

  # Let React handle routing for HTML
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "*path", to: "home#index", constraints: ->(request) { request.format.html? }
end
