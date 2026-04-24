class WorkloadsController < ApplicationController
  before_action :require_current_organization

  STATUS_ORDER = %w[open in_progress in_review blocked done].freeze

  def index
    issues = Issue.includes(:assignee, :project)
    counts = Hash.new { |h, k| h[k] = Hash.new(0) }

    issues.find_each do |issue|
      key = issue.assignee_id
      counts[key][issue.status] += 1
      counts[key][:total] += 1
    end

    assignees = current_organization.users.where(id: counts.keys.compact).index_by(&:id)

    @rows = counts.map do |assignee_id, status_counts|
      {
        user: assignees[assignee_id],
        assignee_id: assignee_id,
        counts: status_counts,
        total: status_counts[:total]
      }
    end.sort_by { |r| -r[:total] }
  end

  private
    def require_current_organization
      return if current_organization
      redirect_to root_path, alert: "Pick an organization first."
    end
end
