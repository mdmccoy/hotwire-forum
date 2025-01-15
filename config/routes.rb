# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :discussions do
    resources :posts, only: %i[create show edit update destroy], module: :discussions
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: 'main#index'
end
