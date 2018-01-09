Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :tickets, only: [:create, :index]
    end
  end

  root 'api/v1/tickets#index'
end
