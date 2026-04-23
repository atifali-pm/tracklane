class AddTriageSuggestionToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :triage_suggestion, :jsonb
  end
end
