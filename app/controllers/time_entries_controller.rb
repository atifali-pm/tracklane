class TimeEntriesController < ApplicationController
  before_action :require_membership
  before_action :set_project_and_issue

  def create
    @entry = @issue.time_entries.build(entry_params)
    @entry.user = Current.user

    if @entry.save
      redirect_to project_issue_path(@project, @issue), notice: "Time logged."
    else
      redirect_to project_issue_path(@project, @issue), alert: @entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    entry = @issue.time_entries.find_by!(id: params[:id])
    unless can_delete?(entry)
      redirect_to project_issue_path(@project, @issue), alert: "You can only delete your own time entries."
      return
    end

    entry.destroy
    redirect_to project_issue_path(@project, @issue), notice: "Time entry removed."
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

    def entry_params
      params.expect(time_entry: %i[minutes occurred_on note])
    end

    def can_delete?(entry)
      return true if %w[admin manager].include?(current_membership&.role.to_s)
      entry.user_id == Current.user.id
    end
end
