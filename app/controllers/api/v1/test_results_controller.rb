module Api
  module V1
    class TestResultsController < ApplicationController
      include Paginatable

      def create
        test_result = TestResult.new(test_result_params)

        if test_result.save
          render json: test_result, status: :created
        else
          render json: { errors: test_result.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        test_results = TestResult.all
        test_results = test_results.where(subject: params[:subject]) if params[:subject].present?
        test_results = test_results.for_date(Date.parse(params[:date])) if params[:date].present?

        render json: paginate(test_results)
      end

      private

      def test_result_params
        params.require(:test_result).permit(:student_name, :subject, :marks, :timestamp)
      end
    end
  end
end
