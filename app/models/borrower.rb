class Borrower < ActiveRecord::Base
	has_many :payments
	has_many :investment_project_assignment

end
