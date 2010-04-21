ActionController::Routing::Routes.draw do |map|
  map.resources :topics, :has_many => :stories, :shallow => true
  map.resources :stories, :only => [:index]

  map.resources :comments

  map.resources :users

  map.resource :session

  #map.resources :stories

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  map.root :controller => 'topics', :action => 'index'
  
  #Sitealizer
  map.connect '/sitealizer/:action', :controller => 'sitealizer'

  #custom routes  
  map.settings '/settings', :controller => 'users', :action => 'settings'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'  
  map.about '/about', :controller => 'static', :action => 'about'
  map.changelog '/changelog', :controller => 'static', :action => 'changelog'  
  map.specs '/specs', :controller => 'static', :action => 'specs'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:reset_code', :controller => 'users', :action => 'reset_password'
  map.update_password_on_reset '/update_password_on_reset', :controller => 'users', :action => 'update_password_on_reset'

  map.tags '/topics/:id/tag/:tag_list', :controller => 'topics', :action => 'tag'  
  map.global_tags '/tag/:tag_list', :controller => 'topics', :action => 'tag'

  map.topical '/topics/:id/:tab/:sort', :controller => 'topics', :action => 'show', :tab => 'all', :sort => 'popular'
  map.connect 'topics/:id', :controller => 'topics', :action => 'show', :tab => 'all', :sort => 'popular'

  map.new_story '/stories/new/:kind', :controller => 'stories', :action => 'new'
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id/:id2'  
end
