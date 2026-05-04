Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :test_results, only: [:create, :index]
      resources :daily_result_statistics, only: [:index]
      resources :monthly_result_averages, only: [:index]
      get 'statistics_summary', to: 'statistics_summary#index'
      get 'top_performers', to: 'top_performers#index'
    end
  end
end
