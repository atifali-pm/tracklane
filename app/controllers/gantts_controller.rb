class GanttsController < ApplicationController
  before_action :require_membership
  before_action :set_project

  def show
    @range_start = (Date.parse(params[:from]) rescue Date.current - 7)
    @range_end   = (Date.parse(params[:to])   rescue Date.current + 30)
    @range_start, @range_end = @range_end, @range_start if @range_start > @range_end

    @days = (@range_start..@range_end).to_a
    @issues = @project.issues.includes(:assignee).scheduled.ordered.reverse
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
