require 'rails_helper'

RSpec.describe 'Api::V1::StatisticsSummary', type: :request do
  describe 'GET /api/v1/statistics_summary' do
    before do
      create(:test_result, student_name: 'Alice', subject: 'Mathematics', marks: 90.0)
      create(:test_result, student_name: 'Bob', subject: 'Mathematics', marks: 70.0)
      create(:test_result, student_name: 'Alice', subject: 'Science', marks: 85.0)
    end

    it 'returns overall statistics summary' do
      get '/api/v1/statistics_summary'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['total_test_results']).to eq(3)
      expect(json['total_subjects']).to eq(2)
      expect(json['subjects'].length).to eq(2)
    end

    it 'returns per-subject breakdown with min, max, and average' do
      get '/api/v1/statistics_summary'

      json = JSON.parse(response.body)
      math_summary = json['subjects'].find { |s| s['subject'] == 'Mathematics' }

      expect(math_summary['total_results']).to eq(2)
      expect(math_summary['overall_low'].to_f).to eq(70.0)
      expect(math_summary['overall_high'].to_f).to eq(90.0)
      expect(math_summary['average_marks'].to_f).to eq(80.0)
    end
  end
end
