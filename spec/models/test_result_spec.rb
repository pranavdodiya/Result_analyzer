require 'rails_helper'

RSpec.describe TestResult, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:student_name) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:marks) }
    it { should validate_presence_of(:timestamp) }

    it { should validate_numericality_of(:marks).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'scopes' do
    let!(:today_result) { create(:test_result, timestamp: Time.current) }
    let!(:yesterday_result) { create(:test_result, timestamp: 1.day.ago) }
    let!(:science_result) { create(:test_result, :science, timestamp: Time.current) }

    describe '.for_date' do
      it 'returns results for a specific date' do
        results = TestResult.for_date(Date.today)
        expect(results).to include(today_result, science_result)
        expect(results).not_to include(yesterday_result)
      end
    end

    describe '.for_subject' do
      it 'returns results for a specific subject' do
        results = TestResult.for_subject('Mathematics')
        expect(results).to include(today_result, yesterday_result)
        expect(results).not_to include(science_result)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:test_result)).to be_valid
    end

    it 'is invalid without a student_name' do
      expect(build(:test_result, student_name: nil)).not_to be_valid
    end

    it 'is invalid with marks above 100' do
      expect(build(:test_result, marks: 101)).not_to be_valid
    end

    it 'is invalid with negative marks' do
      expect(build(:test_result, marks: -1)).not_to be_valid
    end
  end
end
