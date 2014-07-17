Rails.application.routes.draw do

  root 'meta#root'
  get 'about' => 'meta#about'

  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}
  get 'login' => redirect('/users/auth/google_oauth2')

  devise_scope :user do
    delete 'logout' => 'devise/sessions#destroy'
  end

  # haaaack
  if Rails.env.development?
    post '/hit-me', to: 'meta#hit_me'
  end

  resource :user, path: '/me', only: :show

  resources :submissions, only: [:show, :edit, :update]

  resources :results, only: :index

  # currently unsure how to roll this into the resource above
  get 'results/:id(/:scope)' => 'results#show', as: :result

  namespace :admin do
    root 'meta#root'

    resources :users do
      collection do
        get  'import', action: :import
        post 'import', action: :import
      end

      member do
        post 'become', action: :become
      end
    end

    resources :results
    resources :submission_reminder_templates
  end

end
