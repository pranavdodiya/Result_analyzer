require 'rails_helper'

RSpec.describe 'Pagination', type: :request do
  describe 'GET /api/v1/test_results with pagination' do
    before do
      30.times do |i|
        create(:test_result, student_name: "Student #{i}", marks: (50 + i).to_f)
      end
    end

    it 'returns paginated results with default per_page of 25' do
      get '/api/v1/test_results'

      json = JSON.parse(response.body)
      expect(json.length).to eq(25)
      expect(response.headers['X-Total-Count']).to eq('30')
      expect(response.headers['X-Total-Pages']).to eq('2')
      expect(response.headers['X-Current-Page']).to eq('1')
    end

    it 'returns second page of results' do
      get '/api/v1/test_results', params: { page: 2 }

      json = JSON.parse(response.body)
      expect(json.length).to eq(5)
      expect(response.headers['X-Current-Page']).to eq('2')
    end

    it 'supports custom per_page parameter' do
      get '/api/v1/test_results', params: { per_page: 10 }

      json = JSON.parse(response.body)
      expect(json.length).to eq(10)
      expect(response.headers['X-Total-Pages']).to eq('3')
    end
  end
end
