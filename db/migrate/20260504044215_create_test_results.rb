class CreateTestResults < ActiveRecord::Migration[5.2]
  def change
    create_table :test_results do |t|
      t.string :student_name
      t.string :subject
      t.float :marks
      t.datetime :timestamp

      t.timestamps
    end
  end
end
