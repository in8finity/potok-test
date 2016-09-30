class CalculatorController < ApplicationController
	
	def view 
		project = InvestmentProject.first
		real_rate = project.actual_performance_rate
		planned_rate = project.planned_performance_rate
		invested_value = params.delete(:invested_value)
		invested_value = 10000 if invested_value.nil?
		invested_value = invested_value.to_f
		@locale = I18n.locale
		@calculated_interests_data = 
			{
				invested_value: invested_value,
			 	planned_interest: ("%.2f" % (planned_rate*invested_value)),
			 	real_interest: ("%.2f" % (real_rate*invested_value)),
			 	planned_interest_rate: "#{"%.2f" % ((planned_rate*10000)/100.0)}%",
			 	real_interest_rate: "#{"%.2f" % ((real_rate*10000)/100.0)}%",
			 	shift: t(:worser),
			 	currency: t(:currency_ru)
			}
		@rates = 
			{
				real: real_rate*100,
				planned: planned_rate*100
			}

		respond_to do |format|
			format.json { render json: @calculated_interests_data }
			format.html {render :view}
		end
	end
end
