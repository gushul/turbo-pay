
# TODO: check
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  #
  # TODO: add admin to users
  # authenticate :user, -> (u) { u.admin? } do
  mount Sidekiq::Web => '/sidekiq'

  resources :transactions do
    member do
      patch :cancel
    end
  end
end
