Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  apipie
  devise_for :user, only: [:confirmation, :password],
                    controllers: { confirmations: 'confirmations',
                                   passwords: 'passwords' }

  devise_scope :user do
    get 'users/confirmed', to: 'confirmations#confirmed', as: 'confirmed_user'
    get 'passwords/changed', to: 'passwords#changed', as: 'password_changed'
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'login' => 'sessions#create'
        post 'facebook_login' => 'sessions#facebook_login'
        delete 'logout' => 'sessions#destroy'

        resources :users, only: [:create, :show, :update, :index] do
          resources :device_tokens, path: 'tokens', only: [:create]
          resources :user_favorites, path: 'favorites', only: [:create, :update, :destroy, :index]
          get :locations, on: :member
        end
        resources :notifications, only: [:index, :update] do
          put :update_status, on: :collection
        end
        resources :beta_requests, only: [:create]
        resources :email_subscriptions, only: [:create], path: 'subscriptions'
        resources :skills, only: [:index]
        resources :passwords, only: [:create]

        resources :matches, only: [:index]
        resources :session_requests, except: [:edit, :new] do
          post :feedback, on: :member
        end
        resources :session_invitations, only: [:index, :update] do
          post :feedback, on: :member
        end

        namespace :payment do
          resources :cards, only: [:index, :create]
          resources :subscriptions, only: [:index, :create]
          resources :balance, only: [:index] do
            put :withdraw, on: :collection
            get :transactions, on: :collection
            post :debit_card, on: :collection
          end
        end
      end
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
