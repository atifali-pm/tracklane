class ProjectsController < ApplicationController
  before_action :require_membership
  before_action -> { require_role(:admin, :manager) }, only: %i[new create edit update destroy]
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.ordered
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.organization = Current.organization

    if @project.save
      ProjectTemplate.apply!(params[:template], @project, reporter: Current.user) if params[:template].present?
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  private
    def require_membership
      return if current_organization && current_membership
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project
      @project = Project.find_by!(slug: params[:slug])
    end

    def project_params
      params.expect(project: %i[name slug description status])
    end
end
