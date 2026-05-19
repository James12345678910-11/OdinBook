Rails.application.routes.draw do
  devise_for :users, controllers: {
  omniauth_callbacks: "users/omniauth_callbacks"
}


  get "up" => "rails/health#show", as: :rails_health_check


  devise_scope :user do
    root to: "posts#index"
  end

  resources :users, only: %i[index show] do
    collection do
      get :follow_requests
    end
  end

  resources :users do
    resources :posts
    member do
      get :follow_requests, to: "users#follow_requests"
    end
  end


  patch "follows/:id/accept",
        to: "follows#accept",
        as: :accept_follow

  patch "follows/:id/reject",
        to: "follows#reject",
        as: :reject_follow

  resources :follows, only: %i[create destroy]
  resources :posts, only: %i[index new show create destroy edit update] do
  member do
    post :repost
  end
end

resources :likes, only: %i[create destroy]
resources :comments, only: %i[create update destroy]

mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

end
