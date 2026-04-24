class DashboardController < ApplicationController
  def index
    return unless current_organization

    @recent_projects = Project.ordered.includes(:issues).limit(6)
    @my_open_issues = Issue.includes(:project)
                            .where(assignee_id: Current.user.id)
                            .where(status: %i[open in_progress in_review blocked])
                            .order(:due_date)
                            .limit(8)
    @recent_activity = current_organization.activity_events.includes(:actor).ordered.limit(6)
    @pending_invitations_count = current_organization.invitations.pending.count if current_membership&.admin?
  end
end
