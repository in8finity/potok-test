class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :borrower
      t.references :investment_project

      t.monetize :percent_value
      t.monetize :debt_value
      t.monetize :total_value
      t.decimal :actual_rate
      t.datetime :processed_date
      t.date :target_period
      t.timestamps
    end
  end
end
