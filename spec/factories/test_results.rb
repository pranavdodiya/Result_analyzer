FactoryBot.define do
  factory :test_result do
    student_name { "John Doe" }
    subject { "Mathematics" }
    marks { 85.0 }
    timestamp { Time.current }

    trait :low_marks do
      marks { 25.0 }
    end

    trait :high_marks do
      marks { 98.0 }
    end

    trait :science do
      subject { "Science" }
    end
  end
end
