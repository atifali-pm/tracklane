class AddStartDateToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :start_date, :date
  end
end
