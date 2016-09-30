class BorrowerProjectAssignment < ActiveRecord::Base
	belongs_to :investor
	belongs_to :borrower
	belongs_to :investment_project

	def payments
		Payment.payments_for_assignment self
	end

    monetize :debt_value_kopecks, :allow_nil => true
    monetize :monthly_payment_for_debt_kopecks, :allow_nil => true
    monetize :monthly_payment_for_percents_kopecks, :allow_nil => true
    monetize :total_monthly_payment_kopecks, :allow_nil => true
   
    monetize :planned_payments_total_kopecks, :allow_nil => true
   
    monetize :paid_for_percents_kopecks, :allow_nil => true
    monetize :paid_for_debt_kopecks, :allow_nil => true
    monetize :paid_total_kopecks, :allow_nil => true

	# #duration_months - на сколько месяцев
	# #interest_rate - ставка
	# #payment_period  - период выплат
	
	# monetize :monthly_payment_for_debt#monthly_payment_for_debt - ежемесячный по долгу
	# monetize :monthly_payment_for_percents#monthly_payment_for_percents - ежемесячный по процентам
	# monetize :total_monthly_payment#total_monthly_payment - общий ежемесячный платже

	# #overrun_interest_rate - ставка при просрочке(годовых)
	# monetize :planned_payments_total#planned_payments_total - запланированная сумма выплаты

	# monetize :paid_for_percents#paid_for_percents выплаченно %
	# monetize :paid_for_debt#paid_for_value Выплачено ОД
	# monetize :paid_total#paid_total

	#annual_performance_rate - доходность годовых
	

	def is_pennalty_applied? inspection_date
		should = should_be_paid_on_date(inspection_date)		
		paid_for_date(inspection_date)[:total] < should
	end

	def payment_periods_passed inspection_date
		return 0 if inspection_date.to_date < start_period
		distance = 1 + (inspection_date.year * 12 + inspection_date.month) - (start_period.year * 12 + start_period.month)
		distance = duration_months if distance > duration_months
		distance
	end

	def should_be_paid_on_date inspection_date
		passed_periods = payment_periods_passed(inspection_date)
		passed_periods -= 1 if duration_months > 1
		return Money.new(0, :rub) if passed_periods <= 0
		total_monthly_payment*passed_periods
	end

	def setup_dependent_params 
		self.monthly_payment_for_debt = debt_value/duration_months
		self.monthly_payment_for_percents = debt_value*interest_rate/12.0
		self.total_monthly_payment = monthly_payment_for_percents + monthly_payment_for_debt
		self.planned_payments_total = duration_months*total_monthly_payment
		
	end

	def pennalty_percents_payment
		debt_value*overrun_interest_rate/12.0
	end

	def monthly_payment_for_date inspection_date
		return monthly_payment_for_debt + pennalty_percents_payment if is_pennalty_applied? inspection_date
		return total_monthly_payment
	end

	def paid_for_date inspection_date
		result_paid_for_percents = Money.new(0, :rub)
		result_paid_total = Money.new(0, :rub)
		result_paid_for_debt = Money.new(0, :rub)

		payments.where(["processed_date <= ?", inspection_date]).each do |payment|
			result_paid_total += payment.total_value
			result_paid_for_percents += payment.percent_value
			result_paid_for_debt += payment.debt_value
		end

		result = {percents: result_paid_for_percents, debt: result_paid_for_debt, total: result_paid_total}
		result
	end

	def update_cached_details
		self.paid_for_percents = Money.new(0, :rub)
		self.paid_total = Money.new(0, :rub)
		self.paid_for_debt = Money.new(0, :rub)

		payments.each do |payment|
			self.paid_for_percents += payment.percent_value #TODO: remove dependency for the value attribute (it's editable and could cause problem - store it in the payment)
			self.paid_total += payment.total_value
			self.paid_for_debt += payment.debt_value
		end
		if(self.paid_for_debt == 0)
			self.annual_performance_rate = 0.0
		else
			self.annual_performance_rate = self.paid_for_percents/self.paid_for_debt*12.0/duration_months
		end
	end


end
