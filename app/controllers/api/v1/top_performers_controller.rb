module Api
  module V1
    class TopPerformersController < ApplicationController
      def index
        limit = (params[:limit] || 10).to_i
        subject = params[:subject]

        results = TestResult.select(
          'student_name, subject, MAX(marks) as highest_marks, AVG(marks) as average_marks, COUNT(*) as total_tests'
        ).group(:student_name, :subject)

        results = results.where(subject: subject) if subject.present?

        top_students = results.order('average_marks DESC').limit(limit)

        render json: top_students.map { |r|
          {
            student_name: r.student_name,
            subject: r.subject,
            highest_marks: r.highest_marks,
            average_marks: r.average_marks.round(2),
            total_tests: r.total_tests
          }
        }
      end
    end
  end
end
