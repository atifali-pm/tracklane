require "test_helper"

class IssueTriageJobTest < ActiveSupport::TestCase
  setup do
    Mention.delete_all
    Comment.delete_all
    ActivityEvent.delete_all
    Issue.delete_all
    Invitation.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@triage.test").delete_all
    Organization.where(slug: "triage").delete_all

    @org = Organization.create!(name: "Triage Org", slug: "triage")
    @alice = User.create!(email_address: "alice@triage.test", password: "password")
    Membership.create!(user: @alice, organization: @org, role: :admin)
    @project = Project.create!(organization: @org, name: "TP", slug: "tp")
    @issue = Issue.create!(project: @project, reporter: @alice, title: "Login 500s in Safari")
  end

  test "job no-ops when AI is not enabled" do
    with_ai(enabled: false) do
      assert_no_changes -> { @issue.reload.triage_suggestion } do
        IssueTriageJob.perform_now(@issue.id, @org.id)
      end
    end
  end

  test "job writes suggestion and updates the issue when service returns one" do
    with_ai(enabled: true) do
      stubbed = {
        "priority"       => "high",
        "assignee_email" => "alice@triage.test",
        "labels"         => [ "bug", "auth" ],
        "rationale"      => "Safari login regression affects all admins.",
        "model"          => "claude-stub",
        "generated_at"   => Time.current.iso8601
      }

      with_stubbed_service(stubbed) do
        IssueTriageJob.perform_now(@issue.id, @org.id)
      end

      @issue.reload
      assert_equal "high", @issue.triage_suggestion["priority"]
      assert_equal "alice@triage.test", @issue.triage_suggestion["assignee_email"]
    end
  end

  private
    def with_ai(enabled:)
      prev = Rails.application.config.x.ai.enabled
      Rails.application.config.x.ai.enabled = enabled
      yield
    ensure
      Rails.application.config.x.ai.enabled = prev
    end

    def with_stubbed_service(suggestion)
      fake_class = Class.new do
        def initialize(issue) = @issue = issue
        def call = @_suggestion
      end
      fake_class.define_method(:call) { suggestion }

      orig_new = IssueTriageService.method(:new)
      IssueTriageService.define_singleton_method(:new) { |issue| fake_class.new(issue) }
      yield
    ensure
      IssueTriageService.define_singleton_method(:new, orig_new)
    end
end
