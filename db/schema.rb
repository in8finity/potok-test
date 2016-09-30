# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160929162543) do

  create_table "borrower_project_assignments", force: true do |t|
    t.integer  "borrower_id"
    t.integer  "investment_project_id"
    t.integer  "debt_value_kopecks"
    t.string   "debt_value_currency",                   default: "RUB", null: false
    t.date     "start_period"
    t.integer  "duration_months"
    t.decimal  "interest_rate"
    t.decimal  "overrun_interest_rate"
    t.integer  "payment_period"
    t.integer  "monthly_payment_for_debt_kopecks"
    t.string   "monthly_payment_for_debt_currency",     default: "RUB", null: false
    t.integer  "monthly_payment_for_percents_kopecks"
    t.string   "monthly_payment_for_percents_currency", default: "RUB", null: false
    t.integer  "total_monthly_payment_kopecks"
    t.string   "total_monthly_payment_currency",        default: "RUB", null: false
    t.integer  "planned_payments_total_kopecks"
    t.string   "planned_payments_total_currency",       default: "RUB", null: false
    t.integer  "paid_for_percents_kopecks"
    t.string   "paid_for_percents_currency",            default: "RUB", null: false
    t.integer  "paid_for_debt_kopecks"
    t.string   "paid_for_debt_currency",                default: "RUB", null: false
    t.integer  "paid_total_kopecks"
    t.string   "paid_total_currency",                   default: "RUB", null: false
    t.decimal  "annual_performance_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "borrowers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investment_projects", force: true do |t|
    t.string   "name"
    t.float    "actual_performance_rate",  default: 0.0
    t.float    "planned_performance_rate", default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "borrower_id"
    t.integer  "investment_project_id"
    t.integer  "percent_value_kopecks",  default: 0,     null: false
    t.string   "percent_value_currency", default: "RUB", null: false
    t.integer  "debt_value_kopecks",     default: 0,     null: false
    t.string   "debt_value_currency",    default: "RUB", null: false
    t.integer  "total_value_kopecks",    default: 0,     null: false
    t.string   "total_value_currency",   default: "RUB", null: false
    t.decimal  "actual_rate"
    t.datetime "processed_date"
    t.date     "target_period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
