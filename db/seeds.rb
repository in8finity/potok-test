# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

borrower1 = Borrower.new({name: "LLC1"})
borrower1.save
borrower2 = Borrower.new({name: "LLC2"})
borrower2.save
borrower3 = Borrower.new({name: "LLC3"})
borrower3.save

borrower4 = Borrower.new({name: "LLC4"})
borrower4.save

project = InvestmentProject.new({name: "Test"})
project.save
assignment1 = BorrowerProjectAssignment.new ({borrower: borrower1, investment_project: project})
assignment1.debt_value = Money.new(100000000, :rub)
assignment1.interest_rate = 0.3
assignment1.overrun_interest_rate = 0.5
assignment1.duration_months = 6
assignment1.setup_dependent_params
assignment1.start_period = (DateTime.now).to_date
assignment1.save
project.save
assignment2 = BorrowerProjectAssignment.new ({borrower: borrower2, investment_project: project})
assignment2.debt_value = Money.new(100000000, :rub)
assignment2.interest_rate = 0.3
assignment2.overrun_interest_rate = 0.5
assignment2.duration_months = 6
assignment2.setup_dependent_params
assignment2.start_period = (DateTime.now).to_date
assignment2.save
project.save
assignment3 = BorrowerProjectAssignment.new ({borrower: borrower3, investment_project: project})
assignment3.debt_value = Money.new(100000000, :rub)
assignment3.interest_rate = 0.3
assignment3.overrun_interest_rate = 0.5
assignment3.duration_months = 6
assignment3.setup_dependent_params
assignment3.start_period = (DateTime.now).to_date
assignment3.save
project.save

assignment4 = BorrowerProjectAssignment.new ({borrower: borrower4, investment_project: project})
assignment4.debt_value = Money.new(100000000, :rub)
assignment4.interest_rate = 0.3
assignment4.overrun_interest_rate = 0.5
assignment4.duration_months = 6
assignment4.setup_dependent_params
assignment4.start_period = (DateTime.now).to_date
assignment4.save

project.save

(1..6).each do |i|
	payment = Payment.new ({
		total_value: assignment1.total_monthly_payment,
		actual_rate: assignment1.interest_rate,
		debt_value: assignment1.monthly_payment_for_debt,
		percent_value: assignment1.monthly_payment_for_percents,
		borrower: borrower1,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end

(1..3).each do |i|
	payment = Payment.new ({
		total_value: assignment2.total_monthly_payment,
		actual_rate: assignment2.interest_rate,
		debt_value: assignment2.monthly_payment_for_debt,
		percent_value: assignment2.monthly_payment_for_percents,
		borrower: borrower2,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end

assignment2.update_cached_details

final_payment_value = assignment2.debt_value - assignment2.monthly_payment_for_debt*3 + assignment2.monthly_payment_for_percents #Money.new(52500000, :rub)#

payment = Payment.new ({
	total_value: final_payment_value,
	actual_rate: assignment2.interest_rate,
	debt_value: final_payment_value - assignment2.monthly_payment_for_percents,
	percent_value: assignment2.monthly_payment_for_percents,
	borrower: borrower2,
	investment_project: project,
	processed_date: DateTime.now+4.months,
	target_period: (DateTime.now+(3).months).to_date})
payment.save


(1..2).each do |i|
	payment = Payment.new ({
		total_value: assignment3.total_monthly_payment,
		actual_rate: assignment3.interest_rate,
		debt_value: assignment3.monthly_payment_for_debt,
		percent_value: assignment3.monthly_payment_for_percents,
		borrower: borrower3,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end

(3..6).each do |i|
	payment = Payment.new ({
		total_value: assignment3.monthly_payment_for_debt + assignment3.pennalty_percents_payment,
		actual_rate: assignment3.interest_rate,
		debt_value: assignment3.monthly_payment_for_debt,
		percent_value: assignment3.pennalty_percents_payment,
		borrower: borrower3,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end



(1..4).each do |i|
	payment = Payment.new ({
		total_value: assignment4.total_monthly_payment,
		actual_rate: assignment4.interest_rate,
		debt_value: assignment4.monthly_payment_for_debt,
		percent_value: assignment4.monthly_payment_for_percents,
		borrower: borrower4,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end

(5..6).each do |i|
	payment = Payment.new ({
		total_value: assignment4.monthly_payment_for_debt + assignment4.pennalty_percents_payment,
		actual_rate: assignment4.overrun_interest_rate,
		debt_value: assignment4.monthly_payment_for_debt,
		percent_value: assignment4.pennalty_percents_payment,
		borrower: borrower4,
		investment_project: project,
		processed_date: DateTime.now+i.months,
		target_period: (DateTime.now+(i-1).months).to_date})
	payment.save
end



project.update_cached_info
project.save