module Api
  module V1
    class DailyResultStatisticsController < ApplicationController
      def index
        statistics = DailyResultStatistic.all
        statistics = statistics.where(subject: params[:subject]) if params[:subject].present?
        statistics = statistics.where(date: params[:date]) if params[:date].present?

        render json: statistics
      end
    end
  end
end
