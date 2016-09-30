require 'test_helper'

class BorrowerProjectAssignmentTest < ActiveSupport::TestCase
  test "it's saving" do
  	 borrower = Borrower.new({name: "Alex"})
  	 project = InvestmentProject.new({name: "Test"})
  	 assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	 assignment.debt_value = Money.new(1000000, :rub)
  	 assert assignment.save
  	 assert_equal 1, project.borrower_project_assignments.count
  end

  test "it calculates dependent params right way" do
  	borrower = Borrower.create({name: "Alex"})
  	project = InvestmentProject.create({name: "Test"})
  	assignment = BorrowerProjectAssignment.create ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(1000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.duration_months = 6
  	assignment.setup_dependent_params
  	assignment.save

  	assert_equal Money.new(1000000*0.3/12.0, :rub), assignment.monthly_payment_for_percents
  	assert_equal Money.new(1000000/6.0, :rub), assignment.monthly_payment_for_debt
  	assert_equal Money.new(1000000*0.3/12.0+1000000/6.0, :rub), assignment.total_monthly_payment
	assert_equal Money.new(1150002, :rub), assignment.planned_payments_total
	
	project.update_cached_info

	assert_equal 0.0, project.actual_performance_rate
	assert_in_delta 0.3, project.planned_performance_rate, 0.001
  end

  test "payment periods count for start date should be equal to one based months count from start" do
	borrower = Borrower.new({name: "Alex"})
	borrower.save
	project = InvestmentProject.new({name: "Test"})
	project.save
	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
	assignment.debt_value = Money.new(1000000, :rub)
	assignment.interest_rate = 0.3
	assignment.duration_months = 2
	assignment.setup_dependent_params
	assignment.start_period = DateTime.now.to_date
	assignment.save
	project.save
	assert_equal 0, assignment.payment_periods_passed(DateTime.now-1.month)
	assert_equal 1, assignment.payment_periods_passed(DateTime.now)
	assert_equal 2, assignment.payment_periods_passed(DateTime.now+1.month)
	assert_equal 2, assignment.payment_periods_passed(DateTime.now+2.month)
  end

  test "one month credit closed with one time payment" do
  	borrower = Borrower.new({name: "Alex"})
  	borrower.save
  	project = InvestmentProject.new({name: "Test"})
  	project.save
  	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(1000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.duration_months = 1
  	assignment.setup_dependent_params
  	assignment.start_period = DateTime.now.to_date
  	assignment.save
  	project.save

  	payment_value = assignment.total_monthly_payment
  	payment = Payment.create ({
  		total_value: payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now,
  		target_period: DateTime.now.to_date})
  	payment.save

  	assert_equal assignment.planned_payments_total, assignment.paid_for_date(DateTime.now)[:total]
  	assert_equal assignment.planned_payments_total, assignment.should_be_paid_on_date(DateTime.now)
  	assert_equal Money.new(0, :rub), assignment.should_be_paid_on_date(DateTime.now-1.month)
  	assert_equal assignment.planned_payments_total, assignment.should_be_paid_on_date(DateTime.now+1.month)

  	assert_in_delta 0.3, project.actual_performance_rate, 0.001
	assert_in_delta 0.3, project.planned_performance_rate, 0.001
  end

  test "two month credit closed with two times payment" do
  	borrower = Borrower.new({name: "Alex"})
  	borrower.save
  	project = InvestmentProject.new({name: "Test"})
  	project.save
  	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(1000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.duration_months = 2
  	assignment.setup_dependent_params
  	assignment.start_period = (DateTime.now - 2.month).to_date
  	assignment.save
  	project.save

  	
  	payment_value = assignment.total_monthly_payment
  	payment = Payment.new ({
  		total_value: payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now - 1.month,
  		target_period: (DateTime.now - 2.month).to_date})
  	payment.save
	

  	assert_equal assignment.paid_for_date(DateTime.now)[:total], assignment.planned_payments_total/2
  	payment = Payment.new ({
  		total_value: payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now,
  		target_period: (DateTime.now-1).to_date})
  	payment.save
  	

  	assert_equal assignment.paid_for_date(DateTime.now)[:total], assignment.planned_payments_total
  	assert_in_delta 0.3, project.actual_performance_rate, 0.001
	assert_in_delta 0.3, project.planned_performance_rate, 0.001

  end

  test "two month credit two steps with pennalty" do
  	borrower = Borrower.new({name: "Alex"})
  	borrower.save
  	project = InvestmentProject.new({name: "Test"})
  	project.save
  	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(1000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.overrun_interest_rate = 0.5
  	assignment.duration_months = 2
  	assignment.setup_dependent_params
  	assignment.start_period = (DateTime.now).to_date
  	assignment.save
  	project.save

  	
  	payment_value = assignment.total_monthly_payment/2
  	payment = Payment.new ({
  		total_value: payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now,
  		target_period: (DateTime.now).to_date})
  	payment.save
  	
  	assignment.update_cached_details #TODO: remove - it should be called on save

  	assert_equal assignment.paid_for_date(DateTime.now+3.months)[:total], assignment.total_monthly_payment/2
  	assert_equal Money.new(525000, :rub), assignment.monthly_payment_for_date(DateTime.now)
  	assert_equal Money.new(541667, :rub), assignment.monthly_payment_for_date(DateTime.now+3.month)
  	assert_equal Money.new(541667, :rub), assignment.monthly_payment_for_date(DateTime.now+6.month)

  	assert_in_delta 0.3, project.actual_performance_rate, 0.001
	assert_in_delta 0.3, project.planned_performance_rate, 0.001
  end

  test "six month credit return to track" do
  	borrower = Borrower.new({name: "Alex"})
  	borrower.save
  	project = InvestmentProject.new({name: "Test"})
  	project.save
  	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(1000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.overrun_interest_rate = 0.5
  	assignment.duration_months = 6
  	assignment.setup_dependent_params
  	assignment.start_period = (DateTime.now).to_date
  	assignment.save
  	project.save

  	
  	first_payment_value = assignment.total_monthly_payment
  	payment = Payment.new ({
  		total_value: first_payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now+1.months,
  		target_period: (DateTime.now).to_date})
  	payment.save

  	second_payment_value = assignment.should_be_paid_on_date(DateTime.now+3.months) - assignment.paid_for_date(DateTime.now+1.months)[:total] 
  	payment = Payment.new ({
  		total_value: second_payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: second_payment_value - assignment.monthly_payment_for_debt,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now+3.months,
  		target_period: (DateTime.now+2.months).to_date})
  	payment.save

  	third_payment_value = assignment.total_monthly_payment
  	payment = Payment.new ({
  		total_value: third_payment_value,
  		actual_rate: assignment.interest_rate,
  		debt_value: assignment.monthly_payment_for_debt,
  		percent_value: assignment.monthly_payment_for_percents,
  		borrower: borrower,
  		investment_project: project,
  		processed_date: DateTime.now+4.months,
  		target_period: (DateTime.now+3.months).to_date})
  	payment.save

  	
  	assignment.update_cached_details #TODO: remove - it should be called on save

  	assert_equal Money.new(0, :rub), assignment.paid_for_date(DateTime.now)[:total]
  	assert_equal Money.new(first_payment_value, :rub), assignment.paid_for_date(DateTime.now+1.months)[:total]
	assert_equal Money.new(first_payment_value, :rub), assignment.paid_for_date(DateTime.now+2.months)[:total]
	assert_equal Money.new(first_payment_value+second_payment_value, :rub), assignment.paid_for_date(DateTime.now+3.months)[:total]
	assert_equal Money.new(first_payment_value+second_payment_value+third_payment_value, :rub), assignment.paid_for_date(DateTime.now+4.months)[:total]

	assert !assignment.is_pennalty_applied?(DateTime.now)
	assert !assignment.is_pennalty_applied?(DateTime.now+1.months)
	assert assignment.is_pennalty_applied?(DateTime.now+2.months)  #pennalty is applied
	assert !assignment.is_pennalty_applied?(DateTime.now+3.months) #pennalty is removed
	assert !assignment.is_pennalty_applied?(DateTime.now+4.months)

  	assert_equal Money.new(191667, :rub), assignment.monthly_payment_for_date(DateTime.now)
  	assert_equal Money.new(191667, :rub), assignment.monthly_payment_for_date(DateTime.now+1.months)
  	assert_equal Money.new(208334, :rub), assignment.monthly_payment_for_date(DateTime.now+2.months)  	
  	assert_equal Money.new(191667, :rub), assignment.monthly_payment_for_date(DateTime.now+3.months)
  	assert_equal Money.new(191667, :rub), assignment.monthly_payment_for_date(DateTime.now+4.months)
  	
  	assert_in_delta 1.067, project.actual_performance_rate, 0.001
	assert_in_delta 0.3, project.planned_performance_rate, 0.001
  end

  test "six month credit return to track payments" do
  	borrower = Borrower.new({name: "Alex"})
  	borrower.save
  	project = InvestmentProject.new({name: "Test"})
  	project.save
  	assignment = BorrowerProjectAssignment.new ({borrower: borrower, investment_project: project})
  	assignment.debt_value = Money.new(100000000, :rub)
  	assignment.interest_rate = 0.3
  	assignment.overrun_interest_rate = 0.5
  	assignment.duration_months = 6
  	assignment.setup_dependent_params
  	assignment.start_period = (DateTime.now).to_date
  	assignment.save
  	project.save

  	
  	first_payment_value = assignment.total_monthly_payment
  	(1..6).each do |i|
	  	payment = Payment.new ({
	  		total_value: first_payment_value,
	  		actual_rate: assignment.interest_rate,
	  		debt_value: assignment.monthly_payment_for_debt,
	  		percent_value: assignment.monthly_payment_for_percents,
	  		borrower: borrower,
	  		investment_project: project,
	  		processed_date: DateTime.now+i.months,
	  		target_period: (DateTime.now+(i-1).months).to_date})
	  	payment.save
	end
	(1..6).each do |i|
		assert_equal Money.new(first_payment_value*i, :rub), assignment.paid_for_date(DateTime.now+i.months)[:total], "Error on #{i} month paid ammount"
		assert !assignment.is_pennalty_applied?(DateTime.now+i.months)
	end
	assert_in_delta 0.3, project.actual_performance_rate, 0.001
	assert_in_delta 0.3, project.planned_performance_rate, 0.001
  end

end