Rails.application.routes.draw do
  # resources :units
  # resources :spawners
  # resources :games
  # resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'

  post '/user/create' => 'users#create'
end
