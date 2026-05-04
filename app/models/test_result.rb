class TestResult < ApplicationRecord
  validates :student_name, presence: true
  validates :subject, presence: true
  validates :marks, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :timestamp, presence: true

  scope :for_date, ->(date) { where(timestamp: date.beginning_of_day..date.end_of_day) }
  scope :for_subject, ->(subject) { where(subject: subject) }
end
