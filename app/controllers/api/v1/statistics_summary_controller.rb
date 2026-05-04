module Api
  module V1
    class StatisticsSummaryController < ApplicationController
      def index
        render json: {
          total_test_results: TestResult.count,
          total_subjects: TestResult.distinct.count(:subject),
          subjects: subject_summaries,
          latest_daily_statistics: latest_daily_stats,
          latest_monthly_averages: latest_monthly_avgs
        }
      end

      private

      def subject_summaries
        TestResult.group(:subject).pluck(:subject).map do |subject|
          results = TestResult.where(subject: subject)
          {
            subject: subject,
            total_results: results.count,
            overall_low: results.minimum(:marks),
            overall_high: results.maximum(:marks),
            average_marks: results.average(:marks)&.round(2)
          }
        end
      end

      def latest_daily_stats
        DailyResultStatistic.order(date: :desc).limit(5).as_json(except: [:created_at, :updated_at])
      end

      def latest_monthly_avgs
        MonthlyResultAverage.order(month: :desc).limit(3).as_json(except: [:created_at, :updated_at])
      end
    end
  end
end
