VchatManage::Application.routes.draw do

  get "operators/index"

  devise_for :operators

  # The priority is based upon order of creation:
  # first created -> highest priority.
  namespace :admin do
    resources :operators do
      member do
        get "delete"
        get "block"
        get "unblock"
        get "profile"
        get "permission"
        get "session_history"
        get "attendance_history"
        get "attendance_by_date/:date", :action=>"attendance_history", :as=>"attendance_by_date"
      end
      get :autocomplete_skill_name, :on => :collection
      get :message_history, :on => :collection
    end
    resources :pictures do
      member do
        get "delete"
      end
    end
    resources :schedules do
      member do
        get "delete"
      end
      collection do
        get "work_page"
        get "rota_index"
        get "rota_slot/:date/:number", :action=>"rota_slot",:as=>"rota_slot"
        get "cancel/:schedule", :action=>"cancel", :as=>"cancel"
        get "index_by_date/:date", :action=>"index", :as=>"index_by_date"
        get "rindex_by_date/:date", :action=>"rota_index", :as=>"rindex_by_date"
        post "add_operator"
        post "request_holidays"
        post "note"
      end
    end
    resources :skills do
      member do
        get "delete"
      end
    end
    resources :topics do
      member do
        get "delete"
      end
    end
    resources :systemmetas do
      member do
        get "delete"
      end
      get :permission, :on => :collection
      get :market, :on => :collection
      post :marketing, :on => :collection
      post :updates, :on => :collection
    end
    resources :messages do
      member do
        post "read"
      end
      collection do
        get "t/:topic"=>"messages#topic",:as=>"t"
        get "sent"
      end
    end
    resources :users do
      member do
        get "delete"
        get "block"
        get "unblock"
      end
    end
    resources :chat_messages do
      collection do
        get "get_chat_users"
      end
    end 
    resources :permissions
    resources :reminders
    match '/statistics' => 'pages#general'
    match '/statistics/leaderboard' => 'pages#leaderboard'
    match '/statistics/online_ops' => 'pages#online_ops'
    match '/statistics/message_history' => 'pages#message_history'
    match '/statistics/payment_for_ops' => 'pages#payment_for_ops'
    match '/statistics/notes_history' => 'pages#notes_history'
  end
  match "api/login" => 'webservise#login'
  match "api/register" => 'webservise#register'
  match "api/forgotpassword" => 'webservise#forgotpassword'
  match "api/getalloperators" => 'webservise#getalloperators'
  match "api/getrandomagent" => 'webservise#getrandomagent'
  match "api/getlastagent" => 'webservise#getlastagent'
  match "api/getfavoriteoperators" => 'webservise#getfavoriteoperators'
  match "api/getoperatorinfo" => 'webservise#getoperatorinfo'
  match "api/changepassword" => 'webservise#changepassword'
  match "api/changeavatar" => 'webservise#changeavatar'
  match "api/setusercredit" => 'webservise#setusercredit'
  match "api/setrate" => 'webservise#setrate'
  match "api/getrecentoperators" => 'webservise#getrecentoperators'
  match "api/favoriteoperator" => 'webservise#favoriteoperator'
  match "api/unfavoriteoperator" => 'webservise#unfavoriteoperator'
  match "api/getmessagelist" => 'webservise#getmessagelist'
  match "api/sendmessage" => 'webservise#sendmessage'
  match "api/sawdailymessage" => 'webservise#sawdailymessage'
  match "api/endsession" => 'webservise#endsession'
  match "api/getuserinfo" => 'webservise#getuserinfo'
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
  #root :to => redirect("/operators/sign_in")
  root :to => "admin/operators#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
