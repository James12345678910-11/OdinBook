Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }


  get "up" => "rails/health#show", as: :rails_health_check


  devise_scope :user do
    root to: "posts#index"
  end

  resources :users, only: %i[index show] do
    collection do
      get :follow_requests
    end
  end

  resources :follows, only: %i[create destroy]
  resources :posts, only: %i[index new create destroy] do
  member do
    post :repost
  end
end

resources :likes, only: %i[create destroy]
resources :comments, only: %i[create update destroy]


end
