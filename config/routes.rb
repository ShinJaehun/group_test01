Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'posts#index'
  resources :posts
  resources :groups
  resources :users, only:[:show]

  #post 'join_group/:id', to: 'groups#join_group', as: 'join_group'
  post 'apply_group/:id', to: 'groups#apply_group', as: 'apply_group'
  delete 'cancel_apply/:id', to: 'groups#cancel_apply', as: 'cancel_apply'
  post 'approve_user/:id', to: 'groups#approve_user', as: 'approve_user'
  post 'suspend_user/:id', to: 'groups#suspend_user', as: 'suspend_user'
  delete 'leave_group/:id', to: 'groups#leave_group', as: 'leave_group'
end
