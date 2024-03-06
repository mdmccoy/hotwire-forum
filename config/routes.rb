# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :discussions, only: [:index, :new, :create, :edit, :update, :destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: 'main#index'
end
