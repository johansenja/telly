Rails.application.routes.draw do
  mount Telly::Engine => "/telly"

  # should raise error for no UsersController#show
  get "/", to: "users#show"
end
