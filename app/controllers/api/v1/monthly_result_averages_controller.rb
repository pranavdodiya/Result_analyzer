module Api
  module V1
    class MonthlyResultAveragesController < ApplicationController
      def index
        averages = MonthlyResultAverage.all
        averages = averages.where(subject: params[:subject]) if params[:subject].present?

        render json: averages
      end
    end
  end
end
