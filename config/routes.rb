# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :users, only: [:create], path: 'signup'
      resources :reservations, only: [:index]
      post 'login', to: 'sessions#create'
      resources :hotels, only: %i[create update destroy] do
        resources :rooms, only: [] do
          get 'available', on: :collection
          resources :reservations, only: [:create]
        end
      end
    end
  end
end
