require 'rails_helper'

RSpec.describe 'Api::V1::TopPerformers', type: :request do
  describe 'GET /api/v1/top_performers' do
    before do
      create(:test_result, student_name: 'Alice', subject: 'Mathematics', marks: 95.0)
      create(:test_result, student_name: 'Alice', subject: 'Mathematics', marks: 90.0)
      create(:test_result, student_name: 'Bob', subject: 'Mathematics', marks: 75.0)
      create(:test_result, student_name: 'Charlie', subject: 'Science', marks: 88.0)
    end

    it 'returns top performers ordered by average marks' do
      get '/api/v1/top_performers'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.length).to be <= 10
      expect(json.first['student_name']).to eq('Alice')
      expect(json.first['average_marks']).to eq(92.5)
    end

    it 'filters by subject' do
      get '/api/v1/top_performers', params: { subject: 'Science' }

      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['student_name']).to eq('Charlie')
    end

    it 'respects the limit parameter' do
      get '/api/v1/top_performers', params: { limit: 1 }

      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
    end
  end
end
