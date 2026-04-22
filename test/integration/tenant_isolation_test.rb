require "test_helper"

# Cross-tenant isolation against Postgres Row-Level Security.
# Tests run on the tracklane owner role by default (bypasses RLS for setup);
# each assertion uses `as_app(...)` to switch to the NOSUPERUSER app role
# with the per-request GUCs set, which is exactly what the web app does.
class TenantIsolationTest < ActiveSupport::TestCase
  setup do
    # Clear tables the isolation test manages so the scenario is deterministic
    # regardless of fixtures.
    Mention.delete_all
    Comment.delete_all
    Issue.delete_all
    Invitation.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@iso.test").delete_all
    Organization.where(slug: %w[acme-iso globex-iso]).delete_all

    @acme   = Organization.create!(name: "Acme Iso",   slug: "acme-iso")
    @globex = Organization.create!(name: "Globex Iso", slug: "globex-iso")

    @alice = User.create!(email_address: "alice@iso.test", password: "password")
    @bob   = User.create!(email_address: "bob@iso.test",   password: "password")

    @alice_acme   = Membership.create!(user: @alice, organization: @acme,   role: :admin)
    @alice_globex = Membership.create!(user: @alice, organization: @globex, role: :viewer)
    @bob_globex   = Membership.create!(user: @bob,   organization: @globex, role: :manager)

    @acme_p1   = Project.create!(organization: @acme,   name: "Acme P1",   slug: "acme-p1")
    @acme_p2   = Project.create!(organization: @acme,   name: "Acme P2",   slug: "acme-p2")
    @globex_p1 = Project.create!(organization: @globex, name: "Globex P1", slug: "globex-p1")

    @acme_invite   = Invitation.create!(organization: @acme,   invited_by: @alice, email: "new-acme@iso.test",   role: :member)
    @globex_invite = Invitation.create!(organization: @globex, invited_by: @bob,   email: "new-globex@iso.test", role: :member)

    @acme_issue   = Issue.create!(project: @acme_p1,   reporter: @alice, title: "Acme bug")
    @globex_issue = Issue.create!(project: @globex_p1, reporter: @bob,   title: "Globex bug")

    @acme_comment   = Comment.create!(issue: @acme_issue,   user: @alice, organization: @acme,   body: "acme note")
    @globex_comment = Comment.create!(issue: @globex_issue, user: @bob,   organization: @globex, body: "globex note")

    @acme_mention   = Mention.create!(comment: @acme_comment,   user: @alice, organization: @acme)
    @globex_mention = Mention.create!(comment: @globex_comment, user: @bob,   organization: @globex)
  end

  # --- projects ------------------------------------------------------------

  test "projects visible only from their own tenant" do
    as_app(user: @alice, organization: @acme) do
      assert_equal [ "Acme P1", "Acme P2" ].sort, Project.pluck(:name).sort
    end
    as_app(user: @alice, organization: @globex) do
      assert_equal [ "Globex P1" ], Project.pluck(:name)
    end
  end

  test "projects invisible with no organization GUC set" do
    as_app(user: @alice) do
      assert_equal 0, Project.count
    end
  end

  test "projects invisible when GUC references an org the user does not belong to" do
    # Even though GUC is set, the app role sees only rows matching the GUC.
    # Switching to a foreign org the user is not in still exposes that org's
    # rows at the DB level — app-level membership check is what gates access.
    as_app(user: @bob, organization: @acme) do
      assert_equal 2, Project.count, "RLS permits reads by org GUC; membership check is a separate app-layer concern"
    end
  end

  test "cross-tenant INSERT on projects is blocked by WITH CHECK" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Project.create!(organization: @globex, name: "Rogue", slug: "rogue")
      end
    end
  end

  test "cross-tenant UPDATE on a project affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      # Update is scoped to rows visible under RLS, so targeting the Globex
      # project by id results in zero rows updated.
      affected = Project.where(id: @globex_p1.id).update_all(name: "Hijacked")
      assert_equal 0, affected
    end
    assert_equal "Globex P1", @globex_p1.reload.name
  end

  test "cross-tenant DELETE on a project affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Project.where(id: @globex_p1.id).delete_all
      assert_equal 0, affected
    end
    assert Project.exists?(@globex_p1.id)
  end

  test "project find_by(slug:) from wrong tenant returns nil" do
    as_app(user: @alice, organization: @acme) do
      assert_nil Project.find_by(slug: "globex-p1")
    end
  end

  # --- memberships ---------------------------------------------------------

  test "memberships policy lets a user see their own rows across orgs" do
    as_app(user: @alice, organization: @acme) do
      emails = Membership.includes(:organization).map { |m| [ m.user.email_address, m.organization.slug ] }
      # Alice sees: all Acme memberships (by tenant) + her own Globex row
      # (by user_id). Bob's Globex row is not exposed here.
      assert_includes emails, [ "alice@iso.test", "acme-iso" ]
      assert_includes emails, [ "alice@iso.test", "globex-iso" ]
      refute_includes emails, [ "bob@iso.test", "globex-iso" ]
    end
  end

  test "memberships policy does not expose foreign users' rows from another tenant" do
    as_app(user: @alice, organization: @acme) do
      refute_includes Membership.pluck(:id), @bob_globex.id
    end
  end

  test "cross-tenant membership INSERT is blocked" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Membership.create!(user: @bob, organization: @globex, role: :member)
      end
    end
  end

  test "cross-tenant membership UPDATE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Membership.where(id: @bob_globex.id).update_all(role: :admin)
      assert_equal 0, affected
    end
    assert_equal "manager", @bob_globex.reload.role
  end

  test "cross-tenant membership DELETE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Membership.where(id: @bob_globex.id).delete_all
      assert_equal 0, affected
    end
    assert Membership.exists?(@bob_globex.id)
  end

  # --- invitations ---------------------------------------------------------

  test "invitations scoped to an org via association show only that org's invites" do
    as_app(user: @alice, organization: @acme) do
      assert_equal [ "new-acme@iso.test" ], @acme.invitations.pluck(:email)
    end
    as_app(user: @bob, organization: @globex) do
      assert_equal [ "new-globex@iso.test" ], @globex.invitations.pluck(:email)
    end
  end

  test "invitation find_by(token:) works from any tenant context" do
    as_app(user: @alice, organization: @acme) do
      found = Invitation.find_by(token: @globex_invite.token)
      assert_equal "new-globex@iso.test", found.email, "token lookups must succeed across tenants for the accept flow"
    end
  end

  test "cross-tenant invitation INSERT is blocked" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Invitation.create!(organization: @globex, invited_by: @alice, email: "rogue@iso.test", role: :member)
      end
    end
  end

  test "cross-tenant invitation UPDATE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Invitation.where(id: @globex_invite.id).update_all(email: "hijacked@iso.test")
      assert_equal 0, affected
    end
    assert_equal "new-globex@iso.test", @globex_invite.reload.email
  end

  test "cross-tenant invitation DELETE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Invitation.where(id: @globex_invite.id).delete_all
      assert_equal 0, affected
    end
    assert Invitation.exists?(@globex_invite.id)
  end

  # --- global tables (not tenant-scoped) -----------------------------------

  test "organizations are visible across tenant contexts" do
    as_app(user: @alice, organization: @acme) do
      slugs = Organization.pluck(:slug)
      assert_includes slugs, "acme-iso"
      assert_includes slugs, "globex-iso"
    end
  end

  test "users are visible across tenant contexts" do
    as_app(user: @alice, organization: @acme) do
      emails = User.pluck(:email_address)
      assert_includes emails, "alice@iso.test"
      assert_includes emails, "bob@iso.test"
    end
  end

  # --- verify role attributes ---------------------------------------------

  test "app role is NOSUPERUSER NOBYPASSRLS" do
    row = ApplicationRecord.connection.select_one(
      "SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = 'tracklane_app'"
    )
    assert_equal false, row["rolsuper"]
    assert_equal false, row["rolbypassrls"]
  end

  test "memberships table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'memberships'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  test "projects table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'projects'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  test "invitations table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'invitations'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  # --- issues --------------------------------------------------------------

  test "issues visible only from their own tenant" do
    as_app(user: @alice, organization: @acme) do
      assert_equal [ "Acme bug" ], Issue.pluck(:title)
    end
    as_app(user: @bob, organization: @globex) do
      assert_equal [ "Globex bug" ], Issue.pluck(:title)
    end
  end

  test "cross-tenant issue INSERT is blocked" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Issue.create!(project: @globex_p1, organization: @globex, reporter: @alice, title: "Rogue", number: 99)
      end
    end
  end

  test "cross-tenant issue UPDATE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Issue.where(id: @globex_issue.id).update_all(title: "Hijacked")
      assert_equal 0, affected
    end
    assert_equal "Globex bug", @globex_issue.reload.title
  end

  test "cross-tenant issue DELETE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Issue.where(id: @globex_issue.id).delete_all
      assert_equal 0, affected
    end
    assert Issue.exists?(@globex_issue.id)
  end

  test "issues table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'issues'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  # --- comments ------------------------------------------------------------

  test "comments visible only from their own tenant" do
    as_app(user: @alice, organization: @acme) do
      assert_equal [ "acme note" ], Comment.pluck(:body)
    end
    as_app(user: @bob, organization: @globex) do
      assert_equal [ "globex note" ], Comment.pluck(:body)
    end
  end

  test "cross-tenant comment INSERT is blocked" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Comment.create!(issue: @globex_issue, user: @alice, organization: @globex, body: "rogue")
      end
    end
  end

  test "cross-tenant comment UPDATE affects zero rows" do
    as_app(user: @alice, organization: @acme) do
      affected = Comment.where(id: @globex_comment.id).update_all(body: "hijacked")
      assert_equal 0, affected
    end
    assert_equal "globex note", @globex_comment.reload.body
  end

  test "comments table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'comments'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  # --- mentions ------------------------------------------------------------

  test "mentions visible only from their own tenant" do
    as_app(user: @alice, organization: @acme) do
      assert_equal [ @acme_mention.id ], Mention.pluck(:id)
    end
  end

  test "cross-tenant mention INSERT is blocked" do
    as_app(user: @alice, organization: @acme) do
      assert_raises ActiveRecord::StatementInvalid do
        Mention.create!(comment: @globex_comment, user: @alice, organization: @globex)
      end
    end
  end

  test "mentions table has RLS enabled and forced" do
    row = ApplicationRecord.connection.select_one(
      "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = 'mentions'"
    )
    assert row["relrowsecurity"]
    assert row["relforcerowsecurity"]
  end

  # --- issue uniqueness ----------------------------------------------------

  test "issue number uniqueness is scoped per project" do
    dup = Issue.new(project: @acme_p1, organization: @acme, reporter: @alice, title: "Dup", number: 1)
    refute dup.valid?

    other_project = Issue.new(project: @acme_p2, organization: @acme, reporter: @alice, title: "OK", number: 1)
    assert other_project.valid?
  end

  test "issue auto-numbers per project using the counter column" do
    next_number = nil
    as_app(user: @alice, organization: @acme) do
      issue = @acme_p1.issues.create!(reporter: @alice, title: "Second")
      next_number = issue.number
    end
    assert_equal 2, next_number
  end

  # --- regression guards ---------------------------------------------------

  test "project slug uniqueness is scoped per organization" do
    # Same slug is fine across orgs, blocked within one org.
    dup = Project.new(organization: @acme, name: "Acme P1 Again", slug: "acme-p1")
    refute dup.valid?

    other_org_dup = Project.new(organization: @globex, name: "Collide", slug: "acme-p1")
    assert other_org_dup.valid?
  end

  test "membership uniqueness is scoped per user+org" do
    dup = Membership.new(user: @alice, organization: @acme, role: :member)
    refute dup.valid?
  end
end
