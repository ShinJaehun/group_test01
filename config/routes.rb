Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'
  resources :posts
  resources :groups

  post 'add_user_to_group/:id', to: 'groups#add_user_to_group', as: 'add_user_to_group'
  delete 'remove_user_from_group/:id', to: 'groups#remove_user_from_group', as: 'remove_user_from_group'
end
