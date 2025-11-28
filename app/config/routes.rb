Rails.application.routes.draw do
  defaults format: :json do
    post "sign_in", to: "sessions#create"
    post "sign_up", to: "registrations#create"
    resources :sessions, only: [:index, :show, :destroy]
    resource  :password, only: [:edit, :update]
    namespace :identity do
      resource :email,              only: [:edit, :update]
      resource :email_verification, only: [:show, :create]
      resource :password_reset,     only: [:new, :edit, :create, :update]
    end
  end

  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "*path", to: "home#index", constraints: ->(request) { request.format.html? }
end
