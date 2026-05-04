class MonthlyResultAverage < ApplicationRecord
  validates :month, presence: true
  validates :subject, presence: true
  validates :avg_daily_high, presence: true
  validates :avg_daily_low, presence: true
  validates :total_result_count, presence: true
  validates :subject, uniqueness: { scope: :month }
end
