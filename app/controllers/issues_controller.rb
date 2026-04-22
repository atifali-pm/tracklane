class IssuesController < ApplicationController
  before_action :require_membership
  before_action :set_project
  before_action :set_issue, only: %i[show edit update destroy]
  before_action -> { require_role(:admin, :manager, :member) }, only: %i[new create]
  before_action :authorize_issue_write, only: %i[edit update destroy]

  def index
    @issues = @project.issues.includes(:reporter, :assignee).ordered
    @issues = @issues.where(status: params[:status]) if Issue.statuses.key?(params[:status])
  end

  def show
    @comments = @issue.comments.includes(:user, :mentions).ordered
    @comment = Comment.new
  end

  def new
    @issue = @project.issues.build(priority: :medium, status: :open)
    @issue.description = IssueTemplate.body_for(params[:template]) if params[:template].present?
    @eligible_assignees = eligible_assignees
  end

  def create
    @issue = @project.issues.build(issue_params)
    @issue.reporter = Current.user

    if @issue.save
      redirect_to project_issue_path(@project, @issue), notice: "Issue opened."
    else
      @eligible_assignees = eligible_assignees
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @eligible_assignees = eligible_assignees
  end

  def update
    if @issue.update(issue_params)
      redirect_to project_issue_path(@project, @issue), notice: "Issue updated."
    else
      @eligible_assignees = eligible_assignees
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @issue.destroy
    redirect_to project_issues_path(@project), notice: "Issue deleted."
  end

  private
    def require_membership
      return if current_organization && current_membership
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project
      @project = Project.find_by!(slug: params[:project_slug])
    end

    def set_issue
      @issue = @project.issues.find_by!(number: params[:number])
    end

    def issue_params
      params.expect(issue: %i[title description status priority assignee_id due_date])
    end

    def eligible_assignees
      current_organization.users.order(:email_address)
    end

    def authorize_issue_write
      role = current_membership&.role&.to_s
      return if %w[admin manager].include?(role)
      return if role == "member" && @issue.reporter_id == Current.user.id
      redirect_to project_issue_path(@project, @issue), alert: "You can only edit issues you reported."
    end
end
