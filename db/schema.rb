# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2026_05_04_044227) do

  create_table "daily_result_statistics", force: :cascade do |t|
    t.date "date"
    t.string "subject"
    t.float "daily_low"
    t.float "daily_high"
    t.integer "result_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "subject"], name: "index_daily_result_statistics_on_date_and_subject", unique: true
  end

  create_table "monthly_result_averages", force: :cascade do |t|
    t.date "month"
    t.string "subject"
    t.float "avg_daily_high"
    t.float "avg_daily_low"
    t.integer "total_result_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month", "subject"], name: "index_monthly_result_averages_on_month_and_subject", unique: true
  end

  create_table "test_results", force: :cascade do |t|
    t.string "student_name"
    t.string "subject"
    t.float "marks"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject"], name: "index_test_results_on_subject"
    t.index ["timestamp"], name: "index_test_results_on_timestamp"
  end

end
