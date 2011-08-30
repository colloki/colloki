Colloki::Application.routes.draw do
  resources :topics, :shallow => true do
    resources :stories, :only => [:index]
  end
  
  resources :comments, :users, :session

  root :to => 'topics#index'
  
  # sitealizer
  match '/sitealizer/:action', :to => 'sitealizer'

  match '/settings', :to => 'users#settings', :as => 'settings'
  match '/activate/:activation_code', :to => 'users#activate', :as => 'activate'
  match '/signup', :to => 'users#new', :as => 'signup'
  match '/login', :to => 'sessions#new', :as => 'login'
  match '/logout', :to => 'sessions#destroy', :as => 'logout'
  match '/session/create', :to => 'sessions#create', :as => 'create_session'
  match '/about', :to => 'static#about', :as => 'about'
  match '/changelog', :to => 'static#changelog', :as => 'changelog'
  match '/specs', :to => 'static#specs', :as => 'specs'
  match '/change_password', :to => 'users#change_password', :as => 'change_password'
  match '/forgot_password', :to => 'users#forgot_password', :as => 'forgot_password'
  match '/reset_password/:reset_code', :to => 'users#reset_password', :as => 'reset_password'
  match '/update_password_on_reset', :to => 'users#update_password_on_reset', :as => 'update_password_on_reset'

  match '/topics/:id/tag/:tag_list', :to => 'topics#tag', :as => 'tags'
  match '/tag/:tag_list', :to => 'topics#tag', :as => 'global_tags'
  
  match '/topics/:id/:tab/:sort', :to => 'topics#show', :tab => 'all', :sort => 'popular', :as => 'topical'
  match '/topics/:id', :to => 'topics#show', :tab => 'all', :sort => 'popular'
  
  match '/stories/new/:kind', :to => 'stories#new', :as => 'new_story'
  
  match ':controller(/:action(/:id(/:id2)))'
end
