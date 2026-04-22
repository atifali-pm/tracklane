class AmendMembershipsRlsForOwnership < ActiveRecord::Migration[8.1]
  # Memberships need a special-case policy compared to plain tenant-scoped
  # tables. A user must be able to SELECT their own membership rows across
  # every organization they belong to, otherwise the org switcher cannot list
  # the user's orgs when a tenant GUC is already set. Writes, however, must
  # stay restricted to the current tenant so an admin of Acme cannot create
  # or mutate memberships inside Globex.
  #
  # The Phase 1 policy applied the strict tenant rule for ALL commands.
  # Replace it with a split: SELECT = own-or-tenant, INSERT/UPDATE/DELETE
  # = tenant-only.

  def up
    execute <<~SQL
      DROP POLICY IF EXISTS tenant_isolation ON memberships;

      CREATE POLICY memberships_select_own_or_tenant ON memberships
        FOR SELECT
        USING (
          user_id = NULLIF(current_setting('app.current_user_id', true), '')::bigint
          OR organization_id = NULLIF(current_setting('app.current_organization_id', true), '')::bigint
        );

      CREATE POLICY memberships_write_tenant ON memberships
        FOR ALL
        USING (organization_id = NULLIF(current_setting('app.current_organization_id', true), '')::bigint)
        WITH CHECK (organization_id = NULLIF(current_setting('app.current_organization_id', true), '')::bigint);
    SQL
  end

  def down
    execute <<~SQL
      DROP POLICY IF EXISTS memberships_select_own_or_tenant ON memberships;
      DROP POLICY IF EXISTS memberships_write_tenant ON memberships;

      CREATE POLICY tenant_isolation ON memberships
        USING (organization_id = NULLIF(current_setting('app.current_organization_id', true), '')::bigint)
        WITH CHECK (organization_id = NULLIF(current_setting('app.current_organization_id', true), '')::bigint);
    SQL
  end
end
