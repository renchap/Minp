Minp::Application.routes.draw do
  root to: 'home#index'

  resources :projects
end
