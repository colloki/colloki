Colloki::Application.routes.draw do
  resources :provider_authentications

  resources :topics do
    resources :stories
  end
  resources :stories
  resources :comments, :users, :session, :votes
  resources :feeds
  resources :discuss

  root :to => 'topics#latest'

  match 'settings', :to => 'users#settings', :as => 'settings'
  match 'activate/:activation_code', :to => 'users#activate', :as => 'activate'
  match 'signup', :to => 'users#new', :as => 'signup'
  match 'complete_signup', :to => 'provider_authentications#complete_signup', :as => 'complete_signup'
  match 'login', :to => 'sessions#new', :as => 'login'
  match 'logout', :to => 'sessions#destroy', :as => 'logout'
  match 'session/create', :to => 'sessions#create', :as => 'create_session'
  match 'about', :to => 'static#about', :as => 'about'
  match 'changelog', :to => 'static#changelog', :as => 'changelog'
  match 'specs', :to => 'static#specs', :as => 'specs'
  match 'sources', :to => 'static#sources', :as => 'sources'
  match 'change_password', :to => 'users#change_password', :as => 'change_password'
  match 'forgot_password', :to => 'users#forgot_password', :as => 'forgot_password'
  match 'reset_password/:reset_code', :to => 'users#reset_password', :as => 'reset_password'
  match 'update_password_on_reset', :to => 'users#update_password_on_reset', :as => 'update_password_on_reset'

  match 'topics/:id/tag/:tag_list', :to => 'topics#tag', :as => 'tags'
  match 'tag/:tag_list', :to => 'topics#tag', :as => 'global_tags'

  match 'topics/:id/:sort', :to => 'topics#show'
  match 'topics/:id', :to => 'topics#show', :as => 'topical'

  match 'auth/:provider/callback', :to => 'provider_authentications#create'

  match 'latest', :to => 'topics#latest'
  match 'popular', :to => 'topics#popular'
  match 'search', :to => 'topics#search', :as => '/search'
  match 'archive', :to => 'topics#archive'

  match 'feed', :to => 'feeds#latest'

  match ':controller(/:action(/:id(/:id2)))'
end
