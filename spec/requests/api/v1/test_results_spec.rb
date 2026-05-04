require 'rails_helper'

RSpec.describe 'Api::V1::TestResults', type: :request do
  describe 'POST /api/v1/test_results' do
    let(:valid_params) do
      {
        test_result: {
          student_name: 'Alice Smith',
          subject: 'Mathematics',
          marks: 88.5,
          timestamp: '2026-05-04T10:30:00Z'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new test result' do
        expect {
          post '/api/v1/test_results', params: valid_params
        }.to change(TestResult, :count).by(1)
      end

      it 'returns status 201' do
        post '/api/v1/test_results', params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created test result' do
        post '/api/v1/test_results', params: valid_params
        json = JSON.parse(response.body)
        expect(json['student_name']).to eq('Alice Smith')
        expect(json['subject']).to eq('Mathematics')
        expect(json['marks']).to eq(88.5)
      end
    end

    context 'with invalid parameters' do
      it 'returns status 422 when student_name is missing' do
        post '/api/v1/test_results', params: { test_result: { subject: 'Math', marks: 50, timestamp: Time.current } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns status 422 when marks exceed 100' do
        post '/api/v1/test_results', params: {
          test_result: { student_name: 'Bob', subject: 'Math', marks: 150, timestamp: Time.current }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns status 422 when marks are negative' do
        post '/api/v1/test_results', params: {
          test_result: { student_name: 'Bob', subject: 'Math', marks: -5, timestamp: Time.current }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/api/v1/test_results', params: { test_result: { subject: 'Math', marks: 50, timestamp: Time.current } }
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Student name can't be blank")
      end
    end

    context 'simulating MSM service payload' do
      it 'processes a typical MSM payload' do
        msm_payload = {
          test_result: {
            student_name: 'Charlie Brown',
            subject: 'Science',
            marks: 72.0,
            timestamp: '2026-05-04T14:00:00Z'
          }
        }
        post '/api/v1/test_results', params: msm_payload
        expect(response).to have_http_status(:created)
        expect(TestResult.last.student_name).to eq('Charlie Brown')
      end
    end
  end

  describe 'GET /api/v1/test_results' do
    before do
      create(:test_result, student_name: 'Alice', subject: 'Math', timestamp: Time.current)
      create(:test_result, student_name: 'Bob', subject: 'Science', timestamp: Time.current)
    end

    it 'returns all test results' do
      get '/api/v1/test_results'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it 'filters by subject' do
      get '/api/v1/test_results', params: { subject: 'Math' }
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['subject']).to eq('Math')
    end
  end
end
