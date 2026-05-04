require 'rails_helper'

RSpec.describe DailyResultStatisticsCalculator do
  let(:date) { Date.new(2026, 5, 4) }
  let(:calculator) { described_class.new(date: date) }

  describe '#call' do
    context 'with test results for the day' do
      before do
        create(:test_result, subject: 'Mathematics', marks: 90, timestamp: date.to_time + 8.hours)
        create(:test_result, subject: 'Mathematics', marks: 45, timestamp: date.to_time + 9.hours)
        create(:test_result, subject: 'Mathematics', marks: 72, timestamp: date.to_time + 10.hours)
        create(:test_result, subject: 'Science', marks: 88, timestamp: date.to_time + 8.hours)
        create(:test_result, subject: 'Science', marks: 55, timestamp: date.to_time + 9.hours)
      end

      it 'creates daily statistics for each subject' do
        expect { calculator.call }.to change(DailyResultStatistic, :count).by(2)
      end

      it 'calculates correct statistics for Mathematics' do
        calculator.call
        stat = DailyResultStatistic.find_by(date: date, subject: 'Mathematics')
        expect(stat.daily_low).to eq(45.0)
        expect(stat.daily_high).to eq(90.0)
        expect(stat.result_count).to eq(3)
      end

      it 'calculates correct statistics for Science' do
        calculator.call
        stat = DailyResultStatistic.find_by(date: date, subject: 'Science')
        expect(stat.daily_low).to eq(55.0)
        expect(stat.daily_high).to eq(88.0)
        expect(stat.result_count).to eq(2)
      end
    end

    context 'with no test results for the day' do
      it 'does not create any statistics' do
        expect { calculator.call }.not_to change(DailyResultStatistic, :count)
      end
    end

    context 'with single result for a subject' do
      before do
        create(:test_result, subject: 'English', marks: 75, timestamp: date.to_time + 10.hours)
      end

      it 'sets daily_low and daily_high to the same value' do
        calculator.call
        stat = DailyResultStatistic.find_by(date: date, subject: 'English')
        expect(stat.daily_low).to eq(75.0)
        expect(stat.daily_high).to eq(75.0)
        expect(stat.result_count).to eq(1)
      end
    end

    context 'when run multiple times for the same day' do
      before do
        create(:test_result, subject: 'Mathematics', marks: 80, timestamp: date.to_time + 8.hours)
      end

      it 'updates existing records instead of creating duplicates' do
        calculator.call
        expect { calculator.call }.not_to change(DailyResultStatistic, :count)
      end

      it 'updates values when new results are added' do
        calculator.call
        create(:test_result, subject: 'Mathematics', marks: 95, timestamp: date.to_time + 14.hours)
        calculator.call
        stat = DailyResultStatistic.find_by(date: date, subject: 'Mathematics')
        expect(stat.daily_high).to eq(95.0)
        expect(stat.result_count).to eq(2)
      end
    end

    context 'ignores results from other days' do
      before do
        create(:test_result, subject: 'Mathematics', marks: 50, timestamp: date.to_time + 8.hours)
        create(:test_result, subject: 'Mathematics', marks: 100, timestamp: (date - 1.day).to_time + 8.hours)
      end

      it 'only processes results for the specified date' do
        calculator.call
        stat = DailyResultStatistic.find_by(date: date, subject: 'Mathematics')
        expect(stat.daily_high).to eq(50.0)
        expect(stat.result_count).to eq(1)
      end
    end
  end
end
