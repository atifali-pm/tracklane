class CreateDocumentChunks < ActiveRecord::Migration[8.1]
  def up
    create_table :document_chunks do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :source_type, null: false
      t.bigint :source_id,   null: false
      t.text   :content,     null: false
      t.column :embedding, "vector(1536)"
      t.jsonb  :metadata,  null: false, default: {}
      t.integer :token_count

      t.timestamps
    end

    add_index :document_chunks, [ :source_type, :source_id ], unique: true
    add_index :document_chunks, [ :organization_id, :source_type ]

    apply_tenant_rls(:document_chunks)
  end

  def down
    remove_tenant_rls(:document_chunks)
    drop_table :document_chunks
  end
end
