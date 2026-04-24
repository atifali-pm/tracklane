class WikiPagesController < ApplicationController
  before_action :require_membership
  before_action :set_project
  before_action :set_wiki_page, only: %i[show edit update destroy]
  before_action -> { require_role(:admin, :manager, :member) }, only: %i[new create edit update destroy]

  def index
    @wiki_pages = @project.wiki_pages.ordered
  end

  def show
  end

  def new
    @wiki_page = @project.wiki_pages.build
  end

  def create
    @wiki_page = @project.wiki_pages.build(wiki_page_params)
    @wiki_page.last_editor = Current.user

    if @wiki_page.save
      redirect_to project_wiki_page_path(@project, @wiki_page), notice: "Page created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    @wiki_page.last_editor = Current.user
    if @wiki_page.update(wiki_page_params)
      redirect_to project_wiki_page_path(@project, @wiki_page), notice: "Page saved."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @wiki_page.destroy
    redirect_to project_wiki_pages_path(@project), notice: "Page deleted."
  end

  private
    def require_membership
      return if current_organization && current_membership
      redirect_to root_path, alert: "Pick an organization first."
    end

    def set_project
      @project = Project.find_by!(slug: params[:project_slug])
    end

    def set_wiki_page
      @wiki_page = @project.wiki_pages.find_by!(slug: params[:slug])
    end

    def wiki_page_params
      params.expect(wiki_page: %i[title slug body position])
    end
end
