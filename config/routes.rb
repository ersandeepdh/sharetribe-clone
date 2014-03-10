require 'routes/community_domain'
require 'routes/api_request'

Kassi::Application.routes.draw do

    namespace :mercury do
      resources :images
    end

  mount Mercury::Engine => '/'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  match "/robots.txt" => RobotsGenerator

  match "/design" => "design#design"

  # config/routes.rb
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  # Adds locale to every url right after the root path
  scope "(/:locale)" do
    scope :module => "api", :constraints => ApiRequest do
      resources :tokens, :only => :create
      resources :listings do
        resources :comments
      end
      resources :communities do
        member do
          get :classifications
        end
      end
      resources :people do
        resources :conversations do
          member do
            post :messages, :controller => :conversations, :action => "new_message"
          end
        end
        resources :devices
        resources :listings
        resources :feedbacks, :controller => :testimonials
        resources :badges
      end
      
      match 'api_version' => "api#version_check"
      match '/' => 'dashboard#api'    
    end
    
    devise_for :people, :controllers => { :confirmations => "confirmations", :registrations => "people", :omniauth_callbacks => "sessions"}, :path_names => { :sign_in => 'login'} 
    devise_scope :person do  
      # these matches need to be before the general resources to have more priority
      get "/people/confirmation" => "confirmations#show", :as => :confirmation
      put "/people/confirmation" => "confirmations#create"
      match "/people/password/edit" => "devise/passwords#edit"
      post "/people/password" => "devise/passwords#create"
      put "/people/password" => "devise/passwords#update"
      match "/people/sign_up" => redirect("/%{locale}/login")
           
      resources :people do
        collection do
          get :check_username_availability
          get :check_email_availability
          get :check_email_availability_for_new_tribe
          get :check_email_availability_and_validity
          get :check_invitation_code
          get :not_member
          get :cancel
          get :create_facebook_based
          get :fetch_rdf_profile
        end
        member do
          put :activate
          put :deactivate
        end
        resources :listings do
          member do
            put :close
          end  
        end  
        resources :messages, :controller => :conversations do 
          collection do
            get :received
            get :sent
            get :notifications
          end
          member do
            get :accept
            get :reject
            get :confirm
            get :cancel
            put :acceptance
            put :confirmation
          end
          resources :messages
          resources :feedbacks, :controller => :testimonials do
            collection do
              put :skip
            end  
          end
          resources :payments do
            member do
              get :done
            end
          end
          resources :braintree_payments
          
        end
        resource :settings do
          member do
            get :profile
            get :account
            get :notifications
            get :payments
            get :unsubscribe
          end
        end
        resources :invitations # This could be removed, but now saved for a while to keep links in old emails working
        resources :badges
        resources :testimonials
        resources :poll_answers
        resources :emails do
          member do
            post :send_confirmation
          end
        end
      end
      
      # List few specific routes here for Devise to understand those
      match "/signup" => "people#new", :as => :sign_up    
      match "/people/:id/:type" => "people#show", :as => :person_listings    
      
    end

    namespace :admin do
      resources :news_items
      resources :communities do
        member do
          get :edit_details
          get :edit_look_and_feel
          get :edit_welcome_email
          get :test_welcome_email
        end
        resources :emails
      end
      resources :custom_fields do
        collection do
          get :add_option
          post :order
        end
      end
      resources :polls do
        collection do
          get :add_option
          get :remove_option
        end
        member do
          put :open
          put :close
        end
      end
    end
    
    resources :contact_requests
    resources :invitations
    resources :user_feedbacks, :controller => :feedbacks
    resources :homepage do
      collection do
        get :sign_in
        get :not_member
        post :join
      end
    end
    resources :tribes, :controller => :communities do
      collection do 
        get :check_domain_availability
        get :change_form_language
        post :set_organization_email
        post :confirm_organization_email
      end
    end
    resources :community_memberships, :as => :tribe_memberships
    resources :listings do
      member do
        post :follow
        delete :unfollow
      end
      collection do
        get :more_listings
        get :browse
        get :random
        get :locations_json
      end
      resources :images, :controller => :listing_images
      resources :comments
    end

    resources :infos do
      collection do
        get :about
        get :how_to_use
        get :terms
        get :privacy
        get :news
      end  
    end
    resource :terms do
      member do
        post :accept
      end  
    end    
    resources :sessions do
      collection do
        post :request_new_password
        post :change_mistyped_email
      end
    end  
    resources :consent
    resource :sms do
      get :message_arrived
    end
    resources :news_items
    resources :statistics
  end
  
  # Some non-RESTful mappings

  get '/webhooks/braintree' => 'braintree_webhooks#challenge'
  post '/webhooks/braintree' => 'braintree_webhooks#hooks'

  match '/:locale/mercury_update' => "mercury_update#update", :as => :mercury_update, :method => :put
  match '/:locale/api' => "dashboard#api", :as => :api
  match '/:locale/faq' => "dashboard#faq", :as => :faq
  match '/:locale/pricing' => "dashboard#pricing", :as => :pricing
  match '/:locale/dashboard_login' => "dashboard#login", :as => :dashboard_login
  match '/wdc' => 'dashboard#wdc'
  match '/okl' => 'dashboard#okl'
  match '/omakotiliitto' => 'dashboard#okl'
  match '/:locale/admin' => 'admin/news_items#index', :as => :admin
  match '/badges/:style/:id.:format' => "badges#image"
  match "/people/:person_id/inbox/:id", :to => redirect("/fi/people/%{person_id}/messages/%{id}")
  match "/:locale/offers" => "listings#offers", :as => :offers
  match "/:locale/requests" => "listings#requests", :as => :requests
  match "/:locale/people/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation
  match "/:locale/listings/:id/reply" => "conversations#new", :as => :reply_to_listing
  match "/:locale/listings/new/:type/:category" => "listings#new", :as => :new_request_category
  match "/:locale/listings/new/:type" => "listings#new", :as => :new_request
  match "/listings/new/:type" => "listings#new", :as => :new_request_without_locale # needed for some emails, where locale part is already set
  match "/:locale/search" => "search#show", :as => :search
  match "/:locale/logout" => "sessions#destroy", :as => :logout, :method => :delete
  match "/:locale/signup" => "people#new", :as => :sign_up
  match "/:locale/signup/check_captcha" => "people#check_captcha", :as => :check_captcha
  match "/:locale/confirmation_pending" => "sessions#confirmation_pending", :as => :confirmation_pending
  match "/:locale/login" => "sessions#new", :as => :login
  match "/change_locale" => "i18n#change_locale", :as => :change_locale
  match '/:locale/tag_cloud' => "tag_cloud#index", :as => :tag_cloud
  match "/:locale/offers/map/" => "listings#offers_on_map", :as => :offers_on_map
  match "/:locale/requests/map/" => "listings#requests_on_map", :as => :requests_on_map
  match "/:locale/listing_bubble/:id" => "listings#listing_bubble", :as => :listing_bubble
  match "/:locale/listing_bubble_multiple/:ids" => "listings#listing_bubble_multiple", :as => :listing_bubble_multiple
  match '/:locale/:page_type' => 'dashboard#campaign'

  match '/:locale/people/:person_id/settings/payments/braintree/new' => 'braintree_accounts#new', :as => :new_braintree_settings_payment
  match '/:locale/people/:person_id/settings/payments/braintree/show' => 'braintree_accounts#show', :as => :show_braintree_settings_payment
  match '/:locale/people/:person_id/settings/payments/braintree/edit' => 'braintree_accounts#edit', :as => :edit_braintree_settings_payment
  put '/:locale/people/:person_id/settings/payments/braintree/update' => 'braintree_accounts#update', :as => :update_braintree_settings_payment
  match '/:locale/people/:person_id/settings/payments/braintree/create' => 'braintree_accounts#create', :as => :create_braintree_settings_payment

  match '/:locale/people/:person_id/settings/payments/braintree/:id/edit_card' => 'braintree_accounts#edit_card', :as => :edit_card_braintree_settings_payment

  post '/:locale/people/:person_id/settings/payments/braintree/add_card' => 'braintree_accounts#add_card', :as => :add_card_braintree_settings_payment
  post '/:locale/people/:person_id/settings/payments/braintree/update_card' => 'braintree_accounts#update_card', :as => :update_card_braintree_settings_payment

  match '/:locale/people/:person_id/settings/payments/braintree/:id/delete' => 'braintree_accounts#delete_card', :as => :delete_card_braintree_settings_payment
  post '/:locale/people/:person_id/settings/payments/braintree/:id/make_default_card' => 'braintree_accounts#make_default_card', :as => :make_default_card_braintree_settings_payment

  # Inside this constraits are the routes that are used when request has subdomain other than www
  constraints(CommunityDomain) do
    match '/:locale/' => 'homepage#index'
    match '/' => 'homepage#index'
  end  
  
  # Below are the routes that are matched if didn't match inside subdomain constraints
  match '/:locale' => 'dashboard#index'
  
  root :to => 'dashboard#index'
  
end
