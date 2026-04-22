class CreateCommentsAndMentions < ActiveRecord::Migration[8.1]
  def up
    create_table :comments do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

    create_table :mentions do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :mentions, [ :comment_id, :user_id ], unique: true

    apply_tenant_rls(:comments)
    apply_tenant_rls(:mentions)
  end

  def down
    remove_tenant_rls(:mentions)
    remove_tenant_rls(:comments)
    drop_table :mentions
    drop_table :comments
  end
end
