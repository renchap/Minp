Minp::Application.routes.draw do
  get "taskscontroller/show"
  root to: 'home#index'

  resources :projects do
    get 'stream', on: :member
    get 'test', on: :member
  end

  resources :tasks
end
