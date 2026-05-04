FactoryBot.define do
  factory :monthly_result_average do
    month { Date.today.beginning_of_month }
    subject { "Mathematics" }
    avg_daily_high { 92.0 }
    avg_daily_low { 35.0 }
    total_result_count { 250 }
  end
end
