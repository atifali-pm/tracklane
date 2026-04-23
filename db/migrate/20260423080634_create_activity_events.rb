class CreateActivityEvents < ActiveRecord::Migration[8.1]
  def up
    create_table :activity_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id,   null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :activity_events, [ :subject_type, :subject_id ]
    add_index :activity_events, [ :organization_id, :created_at ]

    apply_tenant_rls(:activity_events)
  end

  def down
    remove_tenant_rls(:activity_events)
    drop_table :activity_events
  end
end
