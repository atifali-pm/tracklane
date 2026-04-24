require "test_helper"

class ProjectAsksControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    Mention.delete_all
    Comment.delete_all
    ActivityEvent.delete_all
    Issue.delete_all
    Project.delete_all
    Membership.delete_all
    User.where("email_address LIKE ?", "%@ask.test").delete_all
    Organization.where(slug: "ask").delete_all

    @org = Organization.create!(name: "Ask Org", slug: "ask")
    @alice = User.create!(email_address: "alice@ask.test", password: "password")
    Membership.create!(user: @alice, organization: @org, role: :admin)
    @project = Project.create!(organization: @org, name: "AP", slug: "ap")
    sign_in_as(@alice)
  end

  test "show renders form and AI-off notice when providers are not configured" do
    with_ai(enabled: false) do
      with_embeddings(enabled: false) do
        get project_ask_path(@project)
        assert_response :success
        assert_match "Ask AP", @response.body
        assert_match "AI chat is off", @response.body
      end
    end
  end

  test "create returns the disabled fallback answer when providers are off" do
    with_ai(enabled: false) do
      with_embeddings(enabled: false) do
        post project_ask_path(@project), params: { question: "What is happening?" }
        assert_response :success
        assert_match "AI chat is disabled", @response.body
      end
    end
  end

  test "redirects when no organization context" do
    Membership.where(user: @alice, organization: @org).delete_all
    get project_ask_path(@project)
    assert_redirected_to root_path
  end

  private
    def with_ai(enabled:)
      prev = Rails.application.config.x.ai.enabled
      Rails.application.config.x.ai.enabled = enabled
      yield
    ensure
      Rails.application.config.x.ai.enabled = prev
    end

    def with_embeddings(enabled:)
      prev = Rails.application.config.x.embeddings.enabled
      Rails.application.config.x.embeddings.enabled = enabled
      yield
    ensure
      Rails.application.config.x.embeddings.enabled = prev
    end
end
