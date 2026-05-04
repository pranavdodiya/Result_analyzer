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
        TestResult.group(:subject)
          .select(
            'subject',
            'COUNT(*) as total_results',
            'MIN(marks) as overall_low',
            'MAX(marks) as overall_high',
            'ROUND(AVG(marks), 2) as average_marks'
          )
          .map do |r|
            {
              subject: r.subject,
              total_results: r.total_results,
              overall_low: r.overall_low,
              overall_high: r.overall_high,
              average_marks: r.average_marks.to_f
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
