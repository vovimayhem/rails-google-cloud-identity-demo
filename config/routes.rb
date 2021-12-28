# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#show'

  get 'sign-in', to: 'session#new', as: :new_session
  resource :session, controller: :session, only: %i[create destroy]
end
