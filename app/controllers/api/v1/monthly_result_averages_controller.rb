module Api
  module V1
    class MonthlyResultAveragesController < ApplicationController
      include Paginatable

      def index
        averages = MonthlyResultAverage.all
        averages = averages.where(subject: params[:subject]) if params[:subject].present?

        render json: paginate(averages)
      end
    end
  end
end
