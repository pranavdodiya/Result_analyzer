FactoryBot.define do
  factory :daily_result_statistic do
    date { Date.today }
    subject { "Mathematics" }
    daily_low { 30.0 }
    daily_high { 95.0 }
    result_count { 50 }
  end
end
