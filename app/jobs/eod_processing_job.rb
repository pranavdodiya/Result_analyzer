class EodProcessingJob < ApplicationJob
  queue_as :default

  def perform(date: Date.today)
    # Step 1: Calculate daily result statistics
    DailyResultStatisticsCalculator.new(date: date).call

    # Step 2: Calculate monthly result averages (only runs on specific days)
    MonthlyResultAveragesCalculator.new(date: date).call
  end
end
