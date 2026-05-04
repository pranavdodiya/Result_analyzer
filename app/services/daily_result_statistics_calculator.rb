class DailyResultStatisticsCalculator
  def initialize(date: Date.today)
    @date = date
  end

  def call
    results_by_subject = TestResult.for_date(@date)
      .group(:subject)
      .pluck(:subject, Arel.sql('MIN(marks)'), Arel.sql('MAX(marks)'), Arel.sql('COUNT(*)'))

    results_by_subject.each do |subject, daily_low, daily_high, result_count|
      DailyResultStatistic.find_or_initialize_by(date: @date, subject: subject).tap do |stat|
        stat.daily_low = daily_low
        stat.daily_high = daily_high
        stat.result_count = result_count
        stat.save!
      end
    end
  end
end
