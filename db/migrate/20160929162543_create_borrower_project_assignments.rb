class CreateBorrowerProjectAssignments < ActiveRecord::Migration
  def change
    create_table :borrower_project_assignments do |t|
      t.references :borrower
      t.references :investment_project
      t.money :debt_value, amount: { null: true, default: nil } #value - сумма
      t.date  :start_period
	  t.integer :duration_months #duration_months - на сколько месяцев
	  t.decimal :interest_rate #interest_rate - ставка
	  t.decimal :overrun_interest_rate #overrun_interest_rate - ставка при просрочке(годовых)
	  t.integer :payment_period #payment_period  - период выплат
	
	  t.money :monthly_payment_for_debt, amount: { null: true, default: nil } #monthly_payment_for_debt - ежемесячный по долгу
	  t.money :monthly_payment_for_percents, amount: { null: true, default: nil } #monthly_payment_for_percents - ежемесячный по процентам
	  t.money :total_monthly_payment, amount: { null: true, default: nil } #total_monthly_payment - общий ежемесячный платже
	  

	  t.money :planned_payments_total, amount: { null: true, default: nil }
	  
	  t.money :paid_for_percents, amount: { null: true, default: nil }
	  t.money :paid_for_debt, amount: { null: true, default: nil }
	  t.money :paid_total, amount: { null: true, default: nil }
	  
	  t.decimal :annual_performance_rate
		#planned_payments_total - запланированная сумма выплаты

		#paid_for_percents выплаченно %
		#paid_for_value Выплачено ОД
		#annual_performance_rate - доходность годовых

      t.timestamps
    end
  end
end
