Rails.application.routes.draw do
  root to: 'welcome#index'
  get 'welcome/index'

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  resources :users do
    resources :contacts
  end
end
