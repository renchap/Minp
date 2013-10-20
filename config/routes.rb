Minp::Application.routes.draw do
  root to: 'home#index'

  resources :projects do
    get 'stream', on: :member
  end
end
