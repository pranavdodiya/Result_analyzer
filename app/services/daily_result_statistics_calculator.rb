class DailyResultStatisticsCalculator
  def initialize(date: Date.today)
    @date = date
  end

  def call
    subjects = TestResult.for_date(@date).distinct.pluck(:subject)

    subjects.each do |subject|
      results = TestResult.for_date(@date).for_subject(subject)

      next if results.empty?

      DailyResultStatistic.find_or_initialize_by(date: @date, subject: subject).tap do |stat|
        stat.daily_low = results.minimum(:marks)
        stat.daily_high = results.maximum(:marks)
        stat.result_count = results.count
        stat.save!
      end
    end
  end
end
