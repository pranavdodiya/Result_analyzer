require 'rails_helper'

RSpec.describe MonthlyResultAverage, type: :model do
  describe 'validations' do
    subject { build(:monthly_result_average) }

    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:avg_daily_high) }
    it { should validate_presence_of(:avg_daily_low) }
    it { should validate_presence_of(:total_result_count) }
    it { should validate_uniqueness_of(:subject).scoped_to(:month) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:monthly_result_average)).to be_valid
    end
  end
end
