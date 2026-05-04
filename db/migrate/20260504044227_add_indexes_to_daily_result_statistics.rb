class AddIndexesToDailyResultStatistics < ActiveRecord::Migration[5.2]
  def change
    add_index :daily_result_statistics, [:date, :subject], unique: true
    add_index :monthly_result_averages, [:month, :subject], unique: true
    add_index :test_results, :subject
    add_index :test_results, :timestamp
  end
end
