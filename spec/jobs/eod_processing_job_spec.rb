require 'rails_helper'

RSpec.describe EodProcessingJob, type: :job do
  describe '#perform' do
    let(:date) { Date.new(2026, 5, 4) }

    it 'calls DailyResultStatisticsCalculator' do
      daily_calculator = instance_double(DailyResultStatisticsCalculator)
      monthly_calculator = instance_double(MonthlyResultAveragesCalculator)

      expect(DailyResultStatisticsCalculator).to receive(:new).with(date: date).and_return(daily_calculator)
      expect(daily_calculator).to receive(:call)

      expect(MonthlyResultAveragesCalculator).to receive(:new).with(date: date).and_return(monthly_calculator)
      expect(monthly_calculator).to receive(:call)

      described_class.perform_now(date: date)
    end

    it 'processes daily statistics before monthly averages' do
      call_order = []

      daily_calculator = instance_double(DailyResultStatisticsCalculator)
      monthly_calculator = instance_double(MonthlyResultAveragesCalculator)

      allow(DailyResultStatisticsCalculator).to receive(:new).and_return(daily_calculator)
      allow(MonthlyResultAveragesCalculator).to receive(:new).and_return(monthly_calculator)

      allow(daily_calculator).to receive(:call) { call_order << :daily }
      allow(monthly_calculator).to receive(:call) { call_order << :monthly }

      described_class.perform_now(date: date)
      expect(call_order).to eq([:daily, :monthly])
    end

    context 'integration test' do
      let(:date) { Date.new(2026, 5, 4) }

      before do
        create(:test_result, subject: 'Mathematics', marks: 90, timestamp: date.to_time + 8.hours)
        create(:test_result, subject: 'Mathematics', marks: 40, timestamp: date.to_time + 10.hours)
      end

      it 'creates daily statistics from test results' do
        expect { described_class.perform_now(date: date) }
          .to change(DailyResultStatistic, :count).by(1)

        stat = DailyResultStatistic.last
        expect(stat.subject).to eq('Mathematics')
        expect(stat.daily_low).to eq(40.0)
        expect(stat.daily_high).to eq(90.0)
        expect(stat.result_count).to eq(2)
      end
    end
  end
end
