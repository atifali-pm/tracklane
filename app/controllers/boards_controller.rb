class BoardsController < ApplicationController
  before_action :require_membership
  before_action :set_project

  def show
    issues = @project.issues.includes(:reporter, :assignee).ordered
    @issues_by_status = Issue.statuses.keys.index_with { [] }
    issues.each { |issue| @issues_by_status[issue.status] << issue }
  end

  private
    def require_membership
      return if current_organization && current_membership
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project
      @project = Project.find_by!(slug: params[:project_slug])
    end
end
