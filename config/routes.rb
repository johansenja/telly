Telly::Engine.routes.draw do
  constraints format: :json do
    resources :constant, only: %i[show] do
      resources :method, only: %i[show]
    end

    resources :model, only: %i[show] do
      resources :reflection, only: %i[show]
    end
  end
end
