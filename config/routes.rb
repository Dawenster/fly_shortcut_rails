FlyShortcutRails::Application.routes.draw do
  match 'flights' => 'flights#index', as: :flights
  match 'filter' => 'flights#filter', as: :filter
  match 'visited' => 'flights#visited', as: :visited
  match 'about_us' => 'pages#about_us', as: :about_us
  match 'fbtest' => 'pages#fbtest', as: :fbtest
  match 'best_roundtrips' => 'pages#best_roundtrips', as: :best_roundtrips
  match 'offsite_flight' => 'offsite_flights#redirect', as: :offsite_flight
  match 'ga_test' => 'pages#ga_test', as: :ga_test
  match 'signups' => 'pages#signups', as: :signups
  get "routes-to-scrape" => "flights#routes_to_scrape", :as => :routes_to_scrape
  match 'blog' => 'blogs#index', as: :blogs
  get 'blog/:slug' => 'blogs#show', as: :blog
  resources :users, :only => [:create]
  resources :routes, :except => [:show]
  root :to => 'pages#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
