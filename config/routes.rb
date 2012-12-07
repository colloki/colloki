Colloki::Application.routes.draw do

  #rails_admin
  devise_for :admins, :skip => [:sessions]
  as :admin do
    get 'admins/sign_in' => 'devise/sessions#new', :as => :new_admin_session
    post 'session/admin' => 'devise/sessions#create', :as => :admin_session
    delete 'admins/sign_out' => 'devise/sessions#destroy', :as => :destroy_admin_session
  end
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :provider_authentications

  resources :topics do
    resources :stories
  end

  match 'users/:id', :to => 'users#show', :constraints => { :id =>  /[^\/]+/ }
  resources :stories, :comments, :users, :session, :votes, :follows, :feeds, :discuss

  root :to => 'topics#index'

  match 'settings', :to => 'users#settings', :as => 'settings'
  match 'activate/:activation_code', :to => 'users#activate', :as => 'activate'
  match 'signup', :to => 'users#new', :as => 'signup'
  match 'complete_signup', :to => 'provider_authentications#complete_signup', :as => 'complete_signup'
  match 'login', :to => 'sessions#new', :as => 'login'
  match 'logout', :to => 'sessions#destroy', :as => 'logout'
  match 'session/create', :to => 'sessions#create', :as => 'create_session'
  match 'about', :to => 'static#about', :as => 'about'
  match 'help', :to => 'static#help', :as => 'help'
  match 'research', :to => 'static#about_research', :as => 'research'
  match 'changelog', :to => 'static#changelog', :as => 'changelog'
  match 'specs', :to => 'static#specs', :as => 'specs'
  match 'sources', :to => 'static#sources', :as => 'sources'
  match 'change_password', :to => 'users#change_password', :as => 'change_password'
  match 'forgot_password', :to => 'users#forgot_password', :as => 'forgot_password'
  match 'reset_password/:reset_code', :to => 'users#reset_password', :as => 'reset_password'
  match 'update_password_on_reset', :to => 'users#update_password_on_reset', :as => 'update_password_on_reset'
  match 'whotofollow', :to => 'users#whotofollow'
  match 'tag/:tag_list', :to => 'topics#tag', :as => 'global_tags'

  match 'auth/:provider/callback', :to => 'provider_authentications#create'
  match 'auth/failure', :to => 'provider_authentications#failure'
  match 'search', :to => 'topics#search', :as => '/search'
  match 'feed', :to => 'feeds#latest', :as => 'feed', :format => 'xml'
  match 'events', :to => 'events#index', :as => 'events', :format => 'json'
  match ':controller(/:action(/:id(/:id2)))'
end
