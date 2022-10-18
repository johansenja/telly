Rails.application.routes.draw do
  mount Telly::Engine => "/telly"

  get "/", to: "users#show"
end
