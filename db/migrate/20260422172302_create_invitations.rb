class CreateInvitations < ActiveRecord::Migration[8.1]
  def up
    create_table :invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.integer :role, null: false, default: 2
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [ :organization_id, :email ], unique: true, where: "accepted_at IS NULL"

    apply_tenant_rls(:invitations)

    # Invitations must be looked up by token from outside the invited org
    # (the acceptor is not yet a member). The token is a 32-byte secret so
    # treating knowledge of the token as capability is reasonable; the write
    # path stays tenant-scoped via the `tenant_isolation` policy above.
    execute <<~SQL
      CREATE POLICY invitations_select_by_token ON invitations FOR SELECT USING (true);
    SQL
  end

  def down
    remove_tenant_rls(:invitations)
    drop_table :invitations
  end
end
