class CommentsController < ApplicationController
  before_action :require_membership
  before_action :set_project_and_issue

  def create
    @comment = @issue.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      redirect_to project_issue_path(@project, @issue), notice: "Comment added."
    else
      redirect_to project_issue_path(@project, @issue), alert: @comment.errors.full_messages.to_sentence
    end
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

    def comment_params
      params.expect(comment: %i[body])
    end
end
