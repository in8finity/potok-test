class CreateInvestmentProjects < ActiveRecord::Migration
  def change
    create_table :investment_projects do |t|
      t.string :name
      t.float :actual_performance_rate, default: 0.0
      t.float :planned_performance_rate, default: 0.0
      t.timestamps
    end
  end
end
