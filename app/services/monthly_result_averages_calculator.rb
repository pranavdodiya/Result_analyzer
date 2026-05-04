class MonthlyResultAveragesCalculator
  MINIMUM_RESULT_COUNT = 200

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

    # Find the third Wednesday of this month
    third_wednesday = third_wednesday_of_month(date.year, date.month)

    # The Monday of the week containing the third Wednesday
    monday_of_third_wed_week = third_wednesday - (third_wednesday.wday - 1)

    date == monday_of_third_wed_week
  end

  def self.third_wednesday_of_month(year, month)
    # Find first day of month
    first_day = Date.new(year, month, 1)

    # Find first Wednesday (wday == 3)
    first_wednesday = first_day + ((3 - first_day.wday) % 7)

    # Third Wednesday is 2 weeks after the first
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

    MonthlyResultAverage.find_or_initialize_by(month: month_start, subject: subject).tap do |avg|
      avg.avg_daily_high = selected_stats.sum(&:daily_high) / selected_stats.size.to_f
      avg.avg_daily_low = selected_stats.sum(&:daily_low) / selected_stats.size.to_f
      avg.total_result_count = selected_stats.sum(&:result_count)
      avg.save!
    end
  end

  def select_statistics(statistics)
    selected = []
    cumulative_count = 0

    # Start with last 5 days
    initial_stats = statistics.limit(5).to_a
    selected.concat(initial_stats)
    cumulative_count = selected.sum(&:result_count)

    return selected if cumulative_count >= MINIMUM_RESULT_COUNT

    # Continue going back until we reach 200
    remaining_stats = statistics.offset(5)
    remaining_stats.find_each do |stat|
      selected << stat
      cumulative_count += stat.result_count
      break if cumulative_count >= MINIMUM_RESULT_COUNT
    end

    selected
  end
end
