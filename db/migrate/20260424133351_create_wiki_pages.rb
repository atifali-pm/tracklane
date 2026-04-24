class CreateWikiPages < ActiveRecord::Migration[8.1]
  def up
    create_table :wiki_pages do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project,      null: false, foreign_key: true
      t.references :last_editor,  foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :slug,  null: false
      t.text   :body,  null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :wiki_pages, [ :project_id, :slug ], unique: true

    apply_tenant_rls(:wiki_pages)
  end

  def down
    remove_tenant_rls(:wiki_pages)
    drop_table :wiki_pages
  end
end
