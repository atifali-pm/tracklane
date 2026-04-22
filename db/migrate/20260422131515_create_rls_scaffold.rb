class CreateRlsScaffold < ActiveRecord::Migration[8.1]
  # Row-Level Security template for tenant-scoped tables.
  #
  # Every tenant-scoped table must:
  #   1. Carry `organization_id` (bigint, not null, indexed, foreign key).
  #   2. Enable RLS and force it so even table owners are subject to policy.
  #   3. Carry a policy that restricts rows to `current_setting('app.current_organization_id')`.
  #
  # ApplicationController sets `app.current_organization_id` per-request.
  # Memberships is the first tenant-scoped table. Future scoped tables
  # (projects, issues, comments, wiki_pages, etc.) call apply_tenant_rls
  # from their own migration.

  def up
    apply_tenant_rls(:memberships)
  end

  def down
    remove_tenant_rls(:memberships)
  end

  private

  def apply_tenant_rls(table, tenant_column: :organization_id)
    execute <<~SQL
      ALTER TABLE #{table} ENABLE ROW LEVEL SECURITY;
      ALTER TABLE #{table} FORCE ROW LEVEL SECURITY;

      CREATE POLICY tenant_isolation ON #{table}
        USING (#{tenant_column} = NULLIF(current_setting('app.current_organization_id', true), '')::bigint)
        WITH CHECK (#{tenant_column} = NULLIF(current_setting('app.current_organization_id', true), '')::bigint);
    SQL
  end

  def remove_tenant_rls(table)
    execute <<~SQL
      DROP POLICY IF EXISTS tenant_isolation ON #{table};
      ALTER TABLE #{table} DISABLE ROW LEVEL SECURITY;
    SQL
  end
end
