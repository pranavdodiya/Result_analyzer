require 'rails_helper'

RSpec.describe MonthlyResultAveragesCalculator do
  describe '.third_wednesday_of_month' do
    it 'finds the third Wednesday of May 2026' do
      # May 2026: 1st is Friday, first Wed is May 6, third Wed is May 20
      expect(described_class.third_wednesday_of_month(2026, 5)).to eq(Date.new(2026, 5, 20))
    end

    it 'finds the third Wednesday of January 2026' do
      # Jan 2026: 1st is Thursday, first Wed is Jan 7, third Wed is Jan 21
      expect(described_class.third_wednesday_of_month(2026, 1)).to eq(Date.new(2026, 1, 21))
    end

    it 'finds the third Wednesday of June 2026' do
      # June 2026: 1st is Monday, first Wed is June 3, third Wed is June 17
      expect(described_class.third_wednesday_of_month(2026, 6)).to eq(Date.new(2026, 6, 17))
    end
  end

  describe '.third_wednesday_week_monday?' do
    it 'returns true for the Monday of the third Wednesday week in May 2026' do
      # Third Wed of May 2026 is May 20, so Monday of that week is May 18
      expect(described_class.third_wednesday_week_monday?(Date.new(2026, 5, 18))).to be true
    end

    it 'returns false for other Mondays' do
      expect(described_class.third_wednesday_week_monday?(Date.new(2026, 5, 11))).to be false
      expect(described_class.third_wednesday_week_monday?(Date.new(2026, 5, 25))).to be false
    end

    it 'returns false for non-Monday dates' do
      expect(described_class.third_wednesday_week_monday?(Date.new(2026, 5, 20))).to be false
    end

    it 'returns true for January 2026' do
      # Third Wed of Jan 2026 is Jan 21, Monday of that week is Jan 19
      expect(described_class.third_wednesday_week_monday?(Date.new(2026, 1, 19))).to be true
    end
  end

  describe '#should_run?' do
    it 'returns true on the correct Monday' do
      calculator = described_class.new(date: Date.new(2026, 5, 18))
      expect(calculator.should_run?).to be true
    end

    it 'returns false on other days' do
      calculator = described_class.new(date: Date.new(2026, 5, 4))
      expect(calculator.should_run?).to be false
    end
  end

  describe '#call' do
    context 'when it is not the correct Monday' do
      let(:calculator) { described_class.new(date: Date.new(2026, 5, 4)) }

      it 'does not create any monthly averages' do
        create(:daily_result_statistic, date: Date.new(2026, 5, 1), result_count: 300)
        expect { calculator.call }.not_to change(MonthlyResultAverage, :count)
      end
    end

    context 'when it is the correct Monday' do
      # May 18, 2026 is the Monday of the week containing the third Wednesday (May 20)
      let(:run_date) { Date.new(2026, 5, 18) }
      let(:calculator) { described_class.new(date: run_date) }

      context 'with sufficient results in last 5 days' do
        before do
          5.times do |i|
            create(:daily_result_statistic,
              date: run_date - (i + 1).days,
              subject: 'Mathematics',
              daily_low: 30.0 + i,
              daily_high: 90.0 + i,
              result_count: 50
            )
          end
        end

        it 'creates a monthly average' do
          expect { calculator.call }.to change(MonthlyResultAverage, :count).by(1)
        end

        it 'calculates correct average of daily_high' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          # daily_highs: 90, 91, 92, 93, 94 => avg = 92.0
          expect(avg.avg_daily_high).to eq(92.0)
        end

        it 'calculates correct average of daily_low' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          # daily_lows: 30, 31, 32, 33, 34 => avg = 32.0
          expect(avg.avg_daily_low).to eq(32.0)
        end

        it 'calculates correct total result count' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          expect(avg.total_result_count).to eq(250)
        end

        it 'stores the month as the first of the month' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          expect(avg.month).to eq(Date.new(2026, 5, 1))
        end
      end

      context 'with insufficient results in last 5 days (need to go further back)' do
        before do
          # Last 5 days: only 30 each = 150 total (< 200)
          5.times do |i|
            create(:daily_result_statistic,
              date: run_date - (i + 1).days,
              subject: 'Mathematics',
              daily_low: 25.0 + i,
              daily_high: 85.0 + i,
              result_count: 30
            )
          end
          # Day 6 back: 60 results => cumulative = 210 >= 200
          create(:daily_result_statistic,
            date: run_date - 6.days,
            subject: 'Mathematics',
            daily_low: 20.0,
            daily_high: 80.0,
            result_count: 60
          )
        end

        it 'goes further back to reach minimum 200 result count' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          expect(avg.total_result_count).to eq(210)
        end

        it 'includes all 6 days in the average calculation' do
          calculator.call
          avg = MonthlyResultAverage.find_by(subject: 'Mathematics')
          # daily_highs: 85, 86, 87, 88, 89, 80 => avg = 515/6 = 85.833...
          expect(avg.avg_daily_high).to be_within(0.01).of(85.83)
        end
      end

      context 'with multiple subjects' do
        before do
          %w[Mathematics Science].each do |subj|
            5.times do |i|
              create(:daily_result_statistic,
                date: run_date - (i + 1).days,
                subject: subj,
                daily_low: 30.0,
                daily_high: 90.0,
                result_count: 50
              )
            end
          end
        end

        it 'creates monthly averages for each subject' do
          expect { calculator.call }.to change(MonthlyResultAverage, :count).by(2)
        end
      end

      context 'with no daily statistics' do
        it 'does not create any monthly averages' do
          expect { calculator.call }.not_to change(MonthlyResultAverage, :count)
        end
      end

      context 'when run multiple times' do
        before do
          5.times do |i|
            create(:daily_result_statistic,
              date: run_date - (i + 1).days,
              subject: 'Mathematics',
              daily_low: 30.0,
              daily_high: 90.0,
              result_count: 50
            )
          end
        end

        it 'updates existing records instead of creating duplicates' do
          calculator.call
          expect { calculator.call }.not_to change(MonthlyResultAverage, :count)
        end
      end
    end
  end
end
