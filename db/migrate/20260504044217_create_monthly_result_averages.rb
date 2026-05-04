class CreateMonthlyResultAverages < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_result_averages do |t|
      t.date :month
      t.string :subject
      t.float :avg_daily_high
      t.float :avg_daily_low
      t.integer :total_result_count

      t.timestamps
    end
  end
end
