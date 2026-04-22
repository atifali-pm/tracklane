module IssuesHelper
  STATUS_BADGE_CLASSES = {
    "open"        => "bg-blue-100 text-blue-800",
    "in_progress" => "bg-amber-100 text-amber-800",
    "in_review"   => "bg-purple-100 text-purple-800",
    "done"        => "bg-green-100 text-green-800",
    "blocked"     => "bg-red-100 text-red-800"
  }.freeze

  PRIORITY_BADGE_CLASSES = {
    "low"    => "bg-gray-100 text-gray-600",
    "medium" => "bg-gray-100 text-gray-700",
    "high"   => "bg-orange-100 text-orange-800",
    "urgent" => "bg-red-100 text-red-800"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE_CLASSES[status.to_s] || "bg-gray-100 text-gray-700"
  end

  def priority_badge_class(priority)
    PRIORITY_BADGE_CLASSES[priority.to_s] || "bg-gray-100 text-gray-700"
  end

  def can_edit_issue?(issue)
    role = current_membership&.role&.to_s
    return true if %w[admin manager].include?(role)
    role == "member" && issue.reporter_id == Current.user&.id
  end
end
