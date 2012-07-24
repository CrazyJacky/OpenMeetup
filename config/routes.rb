# -*- encoding : utf-8 -*-

Openmeetup::Application.routes.draw do
  mount WillFilter::Engine => '/will_filter'
  mount Tr8n::Engine => '/tr8n'

  resources :groups do
    member do
      get :events
      get :images
      get :invited
      get :members
      get :waves
    end
    resources :events, :shallow => true do
      resources :event_invitations, :shallow => true
      resources :images, :shallow => true
      member do
        get :users
        get :invited
      end
      resources :absences, :shallow => true do
        collection do
          get :set
        end
      end
      resources :participations, :shallow => true do
        collection do
          get :set
        end
      end
    end
    resources :group_invitations, :shallow => true
    resources :images, :shallow => true
    resources :memberships, :shallow => true do
      collection do
        get :set
      end
    end
    resources :reviews, :shallow => true
    resources :tags, :shallow => true do
      resources :taggings, :shallow => true
    end
  end

  resources :interests do
    resources :interest_taggings, :shallow => true
  end

  resources :passwords
  resource :user_sessions

  resources :tags

  resources :users do
    resources :user_follows, :shallow => true
    collection do
      get :validate_email
    end
    member do
      get :edit_city
      get :activities
      get :facebook_groups
      get :groups
      get :settings
      get :waves
    end
  end

  resources :waves do
    resources :wave_items
  end

  match '/about' => 'root#about', :as => :about
  match '/developer_dashboard' => 'root#developer_dashboard', :as => :developer_dashboard
  match '/search' => 'search#index', :as => :search
  match '/tag_myself' => 'root#tag_myself', :as => :tag_myself
  match '/dashboard' => 'root#dashboard', :as => :dashboard
  match '/intro' => 'root#intro', :as => :intro
  match '/discovery' => 'discovery#index', :as => :discovery

  match '/system' => 'system#index', :as => :system
  match '/reload' => 'system#reload', :as => :reload
  match '/download_database' => 'system#download_database', :as => :download_database

  resources :authentications
  match '/auth/:provider/callback' => 'authentications#create'
  match '/sign_in' => 'user_sessions#new', :as => :sign_in
  match '/sign_out' => 'user_sessions#destroy', :as => :sign_out

  root :to => 'root#index'
  match ':controller(/:action(/:id))(.:format)'
end
