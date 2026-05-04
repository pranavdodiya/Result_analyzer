class DailyResultStatistic < ApplicationRecord
  validates :date, presence: true
  validates :subject, presence: true
  validates :daily_low, presence: true
  validates :daily_high, presence: true
  validates :result_count, presence: true, numericality: { greater_than: 0 }
  validates :subject, uniqueness: { scope: :date }
end
