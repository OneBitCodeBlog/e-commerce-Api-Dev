require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  mount_devise_token_auth_for 'User', at: 'auth/v1/user'
  
  namespace :admin, defaults: { format: :json } do
    namespace :v1 do
      get "home" => "home#index"
      resources :categories
      resources :coupons
      resources :games, only: [], shallow: true do
        resources :licenses
      end
      resources :products
      resources :system_requirements
      resources :users
    end
  end

  namespace :storefront do
    namespace :v1 do
      get "home" => "home#index"
      resources :products, only: [:index, :show]
      resources :categories, only: :index
      resources :checkouts, only: :create
      post "/coupons/:coupon_code/validations", to: "coupon_validations#create"
      resources :wish_items, only: [:index, :create, :destroy]
    end
  end

  namespace :juno do
    namespace :v1 do
      resources :payment_confirmations, only: :create
    end
  end
end
