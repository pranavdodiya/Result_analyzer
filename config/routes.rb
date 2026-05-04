Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :test_results, only: [:create, :index]
      resources :daily_result_statistics, only: [:index]
      resources :monthly_result_averages, only: [:index]
    end
  end
end
