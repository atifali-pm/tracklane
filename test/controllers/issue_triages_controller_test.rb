require "test_helper"

class IssueTriagesControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    Mention.delete_all
    Comment.delete_all
    ActivityEvent.delete_all
    Issue.delete_all
    Invitation.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@triage-ctrl.test").delete_all
    Organization.where(slug: "tctrl").delete_all

    @org = Organization.create!(name: "Triage Ctrl", slug: "tctrl")
    @alice = User.create!(email_address: "alice@triage-ctrl.test", password: "password")
    @bob = User.create!(email_address: "bob@triage-ctrl.test", password: "password")
    Membership.create!(user: @alice, organization: @org, role: :admin)
    Membership.create!(user: @bob, organization: @org, role: :member)

    @project = Project.create!(organization: @org, name: "TP", slug: "tp")
    @issue = Issue.create!(
      project: @project, reporter: @alice, title: "Cache invalidation bug",
      triage_suggestion: {
        "priority" => "high",
        "assignee_email" => "bob@triage-ctrl.test",
        "labels" => [ "bug" ],
        "rationale" => "Affects all cached pages."
      }
    )

    sign_in_as(@alice)
  end

  test "apply updates priority and assignee then clears suggestion" do
    patch project_issue_triage_path(@project, @issue)
    assert_redirected_to project_issue_path(@project, @issue)

    @issue.reload
    assert_equal "high", @issue.priority
    assert_equal @bob.id, @issue.assignee_id
    assert_nil @issue.triage_suggestion
  end

  test "dismiss clears suggestion without touching priority or assignee" do
    delete project_issue_triage_path(@project, @issue)
    assert_redirected_to project_issue_path(@project, @issue)

    @issue.reload
    assert_nil @issue.triage_suggestion
    assert_equal "medium", @issue.priority
    assert_nil @issue.assignee_id
  end

  test "apply skips unknown email assignee quietly" do
    @issue.update!(triage_suggestion: @issue.triage_suggestion.merge("assignee_email" => "nobody@nowhere.test"))
    patch project_issue_triage_path(@project, @issue)

    @issue.reload
    assert_equal "high", @issue.priority
    assert_nil @issue.assignee_id
    assert_nil @issue.triage_suggestion
  end
end
