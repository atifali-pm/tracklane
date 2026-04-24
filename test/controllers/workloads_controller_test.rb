require "test_helper"

class WorkloadsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    Mention.delete_all
    Comment.delete_all
    ActivityEvent.delete_all
    Issue.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@wl.test").delete_all
    Organization.where(slug: "wl").delete_all

    @org = Organization.create!(name: "Workload Org", slug: "wl")
    @alice = User.create!(email_address: "alice@wl.test", password: "password")
    @bob = User.create!(email_address: "bob@wl.test",   password: "password")
    Membership.create!(user: @alice, organization: @org, role: :admin)
    Membership.create!(user: @bob,   organization: @org, role: :member)

    @project = Project.create!(organization: @org, name: "P", slug: "p")
    @project.issues.create!(reporter: @alice, title: "A1", status: :open, assignee: @alice)
    @project.issues.create!(reporter: @alice, title: "A2", status: :in_progress, assignee: @alice)
    @project.issues.create!(reporter: @alice, title: "B1", status: :open, assignee: @bob)
    @project.issues.create!(reporter: @alice, title: "U1", status: :blocked) # unassigned

    sign_in_as(@alice)
  end

  test "renders table with rows per assignee plus unassigned, sorted by total desc" do
    get workload_path
    assert_response :success
    assert_select "h1", /Workload/
    # alice row (2 issues) should come before bob (1) and unassigned (1)
    body = @response.body
    alice_at = body.index("alice@wl.test")
    bob_at = body.index("bob@wl.test")
    unassigned_at = body.index("Unassigned")
    assert alice_at, "alice row present"
    assert bob_at,   "bob row present"
    assert unassigned_at, "unassigned row present"
    assert alice_at < bob_at, "alice (2 issues) before bob (1)"
  end

  test "redirects when no organization context" do
    # Strip membership so current_organization becomes nil on request
    Membership.where(user: @alice, organization: @org).delete_all
    get workload_path
    assert_redirected_to root_path
  end
end
