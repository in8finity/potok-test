class Payment < ActiveRecord::Base
	belongs_to :borrower
	belongs_to :investment_project

	monetize :percent_value_kopecks
    monetize :debt_value_kopecks
    monetize :total_value_kopecks
	#value 
	#process_date - date time
	#target_priod - date
	after_save :update_investment_project

	def update_investment_project
		#investment_project.update_cached_info borrower if borrower
		#investment_project.update_cached_info investor if investor
		investment_project.update_cached_info
	end

	def self.payments_for_assignment assignment
		Payment.where({borrower_id:assignment.borrower_id, investment_project_id:assignment.investment_project_id}).all
	end
end
