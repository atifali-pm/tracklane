class CreateIssuesAndAddCounter < ActiveRecord::Migration[8.1]
  # Adds a per-project issue counter so issue numbers render as
  # project-slug-#1, #2, etc. (mirroring GitHub/Linear conventions) regardless
  # of cross-project activity. organization_id is denormalized onto issues so
  # the tenant RLS policy can filter without joining through projects.

  def up
    add_column :projects, :issues_counter, :integer, null: false, default: 0

    create_table :issues do |t|
      t.references :project, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }
      t.integer :number, null: false
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.date :due_date

      t.timestamps
    end

    add_index :issues, [ :project_id, :number ], unique: true
    add_index :issues, :status
    add_index :issues, :priority

    apply_tenant_rls(:issues)
  end

  def down
    remove_tenant_rls(:issues)
    drop_table :issues
    remove_column :projects, :issues_counter
  end
end
