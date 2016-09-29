class CalculatorController < ApplicationController
	
	def view 
		invested_value = params.delete(:invested_value)
		invested_value = 10000 if invested_value.nil?
		invested_value = invested_value.to_f
		@locale = I18n.locale
		@calculated_interests_data = 
			{
				invested_value: invested_value,
			 	planned_interest: ("%.2f" % (0.3*invested_value)),
			 	real_interest: ("%.2f" % (0.267*invested_value)),
			 	planned_interest_rate: "30%",
			 	real_interest_rate: "26.7%",
			 	shift: t(:worser),
			 	currency: "руб."
			}
		@rates = 
			{
				real: 26.7,
				planned: 30
			}

		respond_to do |format|
			format.json { render json: @calculated_interests_data }
			format.html {render :view}
		end
	end
end
