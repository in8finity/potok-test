class InvestmentProject < ActiveRecord::Base
	has_many :borrowers, through: :borrower_project_assignments
	#has_many :investors, through: :investment_project_assignment
	has_many :borrower_project_assignments

	#actual_interest_rate
	#planned_interest_rate
	#total_invested
	#total_borrowed
	
	has_many :payments

	def update_cached_info
		planned_paid_for_percents_sum = Money.new(0, :rub)
		planned_paid_for_debt_sum = Money.new(0, :rub)
		real_paid_for_percents_sum = Money.new(0, :rub)
		real_paid_for_debt_sum = Money.new(0, :rub)
		durations_sum = 0.0
		items = 0.0
		borrower_project_assignments.each do |assignment|
			#apply all payments for all borrowers cached info - it's done only once per payment save action
			assignment.update_cached_details
			assignment.save

			planned_paid_for_percents_sum += assignment.duration_months*assignment.monthly_payment_for_percents
			planned_paid_for_debt_sum += assignment.duration_months*assignment.monthly_payment_for_debt
			
			real_paid_for_percents_sum += assignment.paid_for_percents
			real_paid_for_debt_sum += assignment.paid_for_debt

			durations_sum += assignment.duration_months
			items += 1
		end
		test_result = {"planned_paid_for_percents_sum": planned_paid_for_percents_sum, "planned_paid_for_debt_sum": planned_paid_for_debt_sum,"real_paid_for_percents_sum": real_paid_for_percents_sum, "real_paid_for_debt_sum":real_paid_for_debt_sum}
		
		durations_sum = 6 if durations_sum == 0
		items = 1 if items == 0
		if(planned_paid_for_debt_sum == 0)
			self.planned_performance_rate = 0.0
		else
			self.planned_performance_rate = (planned_paid_for_percents_sum/planned_paid_for_debt_sum)/(durations_sum/items)*12.0
		end

		if(real_paid_for_debt_sum == 0)
			self.actual_performance_rate = 0.0
		else
			self.actual_performance_rate = (real_paid_for_percents_sum/real_paid_for_debt_sum)/(durations_sum/items)*12
		end
		self
	end

end
