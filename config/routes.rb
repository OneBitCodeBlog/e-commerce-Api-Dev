Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth/v1/user'
  
  namespace :admin, defaults: { format: :json } do
    namespace :v1 do
      get "home" => "home#index"
      resources :categories
      resources :coupons
      resources :licenses
      resources :products
      resources :system_requirements
      resources :users
    end
  end

  namespace :storefront do
    namespace :v1 do
    end
  end
end
