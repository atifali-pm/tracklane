require "test_helper"

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    Mention.delete_all
    Comment.delete_all
    ActivityEvent.delete_all
    Issue.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@cal.test").delete_all
    Organization.where(slug: "cal").delete_all

    @org = Organization.create!(name: "Cal Org", slug: "cal")
    @alice = User.create!(email_address: "alice@cal.test", password: "password")
    Membership.create!(user: @alice, organization: @org, role: :admin)
    @project = Project.create!(organization: @org, name: "CP", slug: "cp")

    # Place one issue with a due date on the 15th of the current month.
    @target_day = Date.current.beginning_of_month + 14
    @issue = @project.issues.create!(
      reporter: @alice,
      title: "Calendared",
      due_date: @target_day
    )

    sign_in_as(@alice)
  end

  test "renders current month grid with today highlighted and month title" do
    get project_calendar_path(@project)
    assert_response :success
    assert_select "h1", Date.current.strftime("%B %Y")
  end

  test "renders issue with due_date on the correct day" do
    get project_calendar_path(@project)
    assert_response :success
    assert_match "#{@issue.number}", @response.body
    assert_match @issue.title, @response.body
  end

  test "accepts ?month= param and shifts the grid" do
    last_month = Date.current.prev_month
    get project_calendar_path(@project, month: last_month)
    assert_response :success
    assert_select "h1", last_month.strftime("%B %Y")
  end

  test "redirects when no organization context" do
    Membership.where(user: @alice, organization: @org).delete_all
    get project_calendar_path(@project)
    assert_redirected_to root_path
  end
end
