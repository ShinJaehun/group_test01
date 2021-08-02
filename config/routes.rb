Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'
  resources :posts
  resources :groups
  resources :users, only:[:show]

  post 'join_group/:id', to: 'groups#join_group', as: 'join_group'
  delete 'leave_group/:id', to: 'groups#leave_group', as: 'leave_group'
end
