# Use this file to define the cron schedule for the whenever gem.
# Learn more: http://github.com/javan/whenever

every 1.day, at: '6:00 pm' do
  runner "EodProcessingJob.perform_now"
end
