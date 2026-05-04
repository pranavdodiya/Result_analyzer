require 'rails_helper'

RSpec.describe 'Api::V1::DailyResultStatistics', type: :request do
  describe 'GET /api/v1/daily_result_statistics' do
    before do
      create(:daily_result_statistic, date: Date.today, subject: 'Math', daily_low: 30, daily_high: 95, result_count: 40)
      create(:daily_result_statistic, date: Date.today, subject: 'Science', daily_low: 45, daily_high: 88, result_count: 25)
    end

    it 'returns all daily statistics' do
      get '/api/v1/daily_result_statistics'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it 'filters by subject' do
      get '/api/v1/daily_result_statistics', params: { subject: 'Math' }
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['subject']).to eq('Math')
    end

    it 'filters by date' do
      create(:daily_result_statistic, date: Date.yesterday, subject: 'Math', daily_low: 20, daily_high: 80, result_count: 10)
      get '/api/v1/daily_result_statistics', params: { date: Date.today.to_s }
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end
  end
end
