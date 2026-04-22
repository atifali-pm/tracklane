class CreateProjects < ActiveRecord::Migration[8.1]
  def up
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :projects, [ :organization_id, :slug ], unique: true

    apply_tenant_rls(:projects)
  end

  def down
    remove_tenant_rls(:projects)
    drop_table :projects
  end
end
