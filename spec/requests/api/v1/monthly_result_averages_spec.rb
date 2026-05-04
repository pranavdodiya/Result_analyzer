require 'rails_helper'

RSpec.describe 'Api::V1::MonthlyResultAverages', type: :request do
  describe 'GET /api/v1/monthly_result_averages' do
    before do
      create(:monthly_result_average, month: Date.today.beginning_of_month, subject: 'Math')
      create(:monthly_result_average, month: Date.today.beginning_of_month, subject: 'Science',
             avg_daily_high: 88.0, avg_daily_low: 40.0, total_result_count: 300)
    end

    it 'returns all monthly averages' do
      get '/api/v1/monthly_result_averages'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it 'filters by subject' do
      get '/api/v1/monthly_result_averages', params: { subject: 'Science' }
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['subject']).to eq('Science')
    end
  end
end
