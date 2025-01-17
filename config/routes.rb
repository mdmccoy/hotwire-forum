# frozen_string_literal: true

Rails.application.routes.draw do
  resources :categories
  devise_for :users

  resources :discussions do
    resources :posts, only: %i[create show edit update destroy], module: :discussions

    collection do
      get 'category/:id', to: "categories/discussions#index", as: :category
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: 'main#index'
end
