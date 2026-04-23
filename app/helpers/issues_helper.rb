module IssuesHelper
  STATUS_BADGE_CLASSES = {
    "open"        => "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-200",
    "in_progress" => "bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-200",
    "in_review"   => "bg-purple-100 text-purple-800 dark:bg-purple-900/40 dark:text-purple-200",
    "done"        => "bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-200",
    "blocked"     => "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-200"
  }.freeze

  PRIORITY_BADGE_CLASSES = {
    "low"    => "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400",
    "medium" => "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300",
    "high"   => "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-200",
    "urgent" => "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-200"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE_CLASSES[status.to_s] || "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300"
  end

  def priority_badge_class(priority)
    PRIORITY_BADGE_CLASSES[priority.to_s] || "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300"
  end

  def can_edit_issue?(issue)
    role = current_membership&.role&.to_s
    return true if %w[admin manager].include?(role)
    role == "member" && issue.reporter_id == Current.user&.id
  end
end
