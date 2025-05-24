# config/routes.rb
Rails.application.routes.draw do
  # Override Devise's registrations controller
  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  resources :jobs do
    resources :applications, only: [:new, :create] do
      collection do
        post :analyze_resume  # Route: POST /jobs/:job_id/applications/analyze_resume
      end
    end
  end

  
  resources :jobs do
    resources :applications, except: [:index, :destroy] do
      member do
        post :retry_analysis
      end
    end
  end

  # Add standalone applications routes for user's own applications
  resources :applications, only: [:index, :show, :edit, :update, :destroy]

  # User profile routes
  resources :users, only: [:show], param: :username
  
  root "home#index"
  get '/profile', to: 'users#edit'
  patch '/profile', to: 'users#update'
  get '/my_applications', to: 'applications#my_applications'
  get '/welcome', to: 'home#welcome'

  get "up" => "rails/health#show", as: :rails_health_check
end