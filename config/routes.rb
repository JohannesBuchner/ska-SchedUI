SchedUI::Application.routes.draw do
  resources :schedules

  resources :jobs

  resources :constraints

  resources :constraints do
    resources :sources
  end
#
  resources :jobs do
    resources :constraints
    resources :bad_dates
  end
#
  resources :bad_dates
#
  resources :sources

  resources :proposals do
    resources :jobs
  end

  resources :process

  resources :reschedule
  
  match 'reschedule/new' => 'reschedule#new'
  match 'reschedule/generate' => 'reschedule#new'
  match 'view' => 'reschedule#index'
  match 'view/:time' => 'reschedule#show'
  match 'view/:time/:filename' => 'reschedule#show', :format => false
  
  resources :job_time_preferences
  # match 'job_time_preferences/dynamicindex', :as => "taken_toggle_present",  :to => "presents#taken_toggle"

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
