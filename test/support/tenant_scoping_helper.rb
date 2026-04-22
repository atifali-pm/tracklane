module TenantScopingHelper
  # Switches the current test transaction to the non-superuser app role and
  # sets the per-request GUCs so RLS enforces inside the block. This
  # simulates what the TenantScoping controller concern does at runtime.
  # Outside the block, the connection reverts to the owner (test default).
  def as_app(user: nil, organization: nil)
    conn = ApplicationRecord.connection
    conn.transaction(requires_new: true) do
      conn.execute("SET LOCAL ROLE tracklane_app")
      conn.execute("SET LOCAL app.current_user_id = #{user.id.to_i}") if user
      conn.execute("SET LOCAL app.current_organization_id = #{organization.id.to_i}") if organization
      yield
      raise ActiveRecord::Rollback
    end
  end
end
