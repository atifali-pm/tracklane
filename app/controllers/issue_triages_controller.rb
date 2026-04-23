class IssueTriagesController < ApplicationController
  before_action :require_membership
  before_action :set_project_and_issue

  def update
    suggestion = @issue.triage_suggestion || {}
    apply_suggestion(suggestion)
    @issue.update!(triage_suggestion: nil)

    redirect_to project_issue_path(@project, @issue), notice: "Suggestion applied."
  end

  def destroy
    @issue.update!(triage_suggestion: nil)
    redirect_to project_issue_path(@project, @issue), notice: "Suggestion dismissed."
  end

  private
    def require_membership
      return if current_organization && current_membership
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project_and_issue
      @project = Project.find_by!(slug: params[:project_slug])
      @issue = @project.issues.find_by!(number: params[:issue_number])
    end

    def apply_suggestion(suggestion)
      updates = {}

      if (priority = suggestion["priority"]) && Issue.priorities.key?(priority)
        updates[:priority] = priority
      end

      if (email = suggestion["assignee_email"]).present?
        user = User.find_by(email_address: email)
        if user && Membership.exists?(user_id: user.id, organization_id: @issue.organization_id)
          updates[:assignee_id] = user.id
        end
      end

      @issue.update!(updates) if updates.any?
    end
end
