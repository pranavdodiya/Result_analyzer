require 'rails_helper'

RSpec.describe DailyResultStatistic, type: :model do
  describe 'validations' do
    subject { build(:daily_result_statistic) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:daily_low) }
    it { should validate_presence_of(:daily_high) }
    it { should validate_presence_of(:result_count) }
    it { should validate_numericality_of(:result_count).is_greater_than(0) }
    it { should validate_uniqueness_of(:subject).scoped_to(:date) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:daily_result_statistic)).to be_valid
    end
  end
end
