class ProjectAsksController < ApplicationController
  before_action :require_membership
  before_action :set_project

  def show
    @question = nil
    @result = nil
  end

  def create
    @question = params[:question].to_s

    if ProjectAskService.enabled?
      @result = ProjectAskService.new(@project, @question).call
    else
      @result = {
        answer: "AI chat is disabled. Set ANTHROPIC_API_KEY and OPENAI_API_KEY and restart the server.",
        chunks: []
      }
    end

    render :show
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
