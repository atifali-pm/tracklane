class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def up
    create_table :time_entries do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.integer :minutes,  null: false
      t.date    :occurred_on, null: false
      t.string  :note

      t.timestamps
    end

    add_index :time_entries, [ :issue_id, :occurred_on ]
    add_index :time_entries, [ :user_id, :occurred_on ]

    apply_tenant_rls(:time_entries)
  end

  def down
    remove_tenant_rls(:time_entries)
    drop_table :time_entries
  end
end
