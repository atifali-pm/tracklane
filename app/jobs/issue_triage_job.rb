class IssueTriageJob < ApplicationJob
  queue_as :default

  discard_on IssueTriageService::NotEnabledError

  # Solid Queue workers run outside any tenant request, so the app role's RLS
  # policies would hide every issue unless we re-establish the GUCs. We pass
  # organization_id alongside issue_id so the job can scope the connection
  # before issuing any SELECT.
  def perform(issue_id, organization_id)
    return unless IssueTriageService.enabled?

    ActivityEvent.with_organization_guc(organization_id) do
      issue = Issue.find_by(id: issue_id)
      return unless issue
      return if issue.triage_suggestion.present?

      suggestion = IssueTriageService.new(issue).call
      return if suggestion.blank?

      issue.update!(triage_suggestion: suggestion)
      Turbo::StreamsChannel.broadcast_replace_to(
        [ issue, :triage ],
        target: dom_id(issue, :triage),
        partial: "issues/triage_suggestion",
        locals: { project: issue.project, issue: issue, suggestion: suggestion }
      )
    end
  rescue StandardError => e
    Rails.logger.warn("IssueTriageJob failed for issue #{issue_id}: #{e.class}: #{e.message}")
    raise if Rails.env.test?
  end

  private
    def dom_id(record, prefix = nil)
      ActionView::RecordIdentifier.dom_id(record, prefix)
    end
end
