class EodProcessingJob < ApplicationJob
  queue_as :default

  def perform(date: Date.today)
    Rails.logger.info "[EOD] Starting end-of-day processing for #{date}"

    Rails.logger.info "[EOD] Calculating daily result statistics..."
    DailyResultStatisticsCalculator.new(date: date).call

    Rails.logger.info "[EOD] Calculating monthly result averages..."
    MonthlyResultAveragesCalculator.new(date: date).call

    Rails.logger.info "[EOD] End-of-day processing completed for #{date}"
  end
end
