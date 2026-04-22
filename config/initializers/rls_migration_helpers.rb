module RlsMigrationHelpers
  # Apply strict tenant RLS to a table: every SELECT / INSERT / UPDATE / DELETE
  # is restricted to rows where `tenant_column` equals the
  # `app.current_organization_id` GUC. Tables that need special-case policies
  # (e.g. memberships letting a user see own rows across tenants) should
  # write the policy inline rather than using this helper.
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

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Migration.include(RlsMigrationHelpers)
end
