class MonthlyResultAveragesCalculator
  MINIMUM_RESULT_COUNT = 200
  INITIAL_LOOKBACK_DAYS = 5

  def initialize(date: Date.today)
    @date = date
  end

  def call
    return unless should_run?

    subjects = DailyResultStatistic.distinct.pluck(:subject)

    subjects.each do |subject|
      calculate_for_subject(subject)
    end
  end

  def should_run?
    self.class.third_wednesday_week_monday?(@date)
  end

  def self.third_wednesday_week_monday?(date)
    return false unless date.monday?

    third_wednesday = third_wednesday_of_month(date.year, date.month)
    monday_of_third_wed_week = third_wednesday - (third_wednesday.wday - 1)

    date == monday_of_third_wed_week
  end

  def self.third_wednesday_of_month(year, month)
    first_day = Date.new(year, month, 1)
    first_wednesday = first_day + ((3 - first_day.wday) % 7)
    first_wednesday + 14
  end

  private

  def calculate_for_subject(subject)
    statistics = DailyResultStatistic
      .where(subject: subject)
      .where('date <= ?', @date)
      .order(date: :desc)

    selected_stats = select_statistics(statistics)

    return if selected_stats.empty?

    month_start = @date.beginning_of_month
    avg_high = selected_stats.sum(&:daily_high) / selected_stats.size.to_f
    avg_low = selected_stats.sum(&:daily_low) / selected_stats.size.to_f
    total_count = selected_stats.sum(&:result_count)

    MonthlyResultAverage.find_or_initialize_by(month: month_start, subject: subject).tap do |avg|
      avg.avg_daily_high = avg_high
      avg.avg_daily_low = avg_low
      avg.total_result_count = total_count
      avg.save!
    end
  end

  def select_statistics(statistics)
    selected = []
    cumulative_count = 0

    initial_stats = statistics.limit(INITIAL_LOOKBACK_DAYS).to_a
    selected.concat(initial_stats)
    cumulative_count = selected.sum(&:result_count)

    return selected if cumulative_count >= MINIMUM_RESULT_COUNT

    remaining_stats = statistics.offset(INITIAL_LOOKBACK_DAYS)
    remaining_stats.find_each do |stat|
      selected << stat
      cumulative_count += stat.result_count
      break if cumulative_count >= MINIMUM_RESULT_COUNT
    end

    selected
  end
end
