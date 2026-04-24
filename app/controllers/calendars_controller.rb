class CalendarsController < ApplicationController
  before_action :require_current_organization
  before_action :set_project

  def show
    base = (Date.parse(params[:month]) rescue Date.current).beginning_of_month
    @current_month = base
    @prev_month = base.prev_month
    @next_month = base.next_month

    range_start = base.beginning_of_week(:sunday)
    range_end = (base.end_of_month.end_of_week(:sunday))
    @days = (range_start..range_end).to_a

    @issues_by_day = Hash.new { |h, k| h[k] = [] }
    @project.issues
            .includes(:assignee, :reporter)
            .where(due_date: range_start..range_end)
            .each { |i| @issues_by_day[i.due_date] << i }
  end

  private
    def require_current_organization
      return if current_organization
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project
      @project = Project.find_by!(slug: params[:project_slug])
    end
end
