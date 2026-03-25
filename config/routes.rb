Rails.application.routes.draw do
  namespace :admin do
    root to: "users#index"
    delete "logout", to: "sessions#destroy_current"
    resources :sessions
    resources :users
  end

  defaults format: :json do
    post "sign_in", to: "sessions#create"
    post "sign_up", to: "registrations#create"
    delete "sign_out", to: "sessions#destroy_current"
    get "current_user", to: "current_user#show"
    get "rollbar", to: "rollbar#show"
    get "payment_options", to: "payment_options#show"
    resources :sessions, only: [ :index, :show, :destroy ]
    resources :payment_methods, only: [ :index, :show, :create ]
    resources :payments, only: [ :index, :show, :create ]
    resources :subscriptions, only: [ :index, :show, :create ]
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
