Rails.application.routes.draw do
  devise_for :users

  resources :jobs do
    resources :applications, only: [ :new, :create ]
  end

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
