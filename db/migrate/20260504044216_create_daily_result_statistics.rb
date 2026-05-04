class CreateDailyResultStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_result_statistics do |t|
      t.date :date
      t.string :subject
      t.float :daily_low
      t.float :daily_high
      t.integer :result_count

      t.timestamps
    end
  end
end
