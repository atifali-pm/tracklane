module ActivityEventsHelper
  ACTION_ICONS = {
    "issue.opened"         => "·",
    "issue.moved"          => "→",
    "issue.assigned"       => "@",
    "comment.created"      => "💬",
    "project.created"      => "+",
    "membership.created"   => "+",
    "invitation.created"   => "✉"
  }.freeze

  def activity_icon(event)
    ACTION_ICONS[event.action] || "•"
  end

  def activity_description(event)
    meta = event.metadata || {}
    actor = event.actor&.email_address || "Someone"

    case event.action
    when "issue.opened"
      project = meta["project_slug"] || "a project"
      "#{actor} opened #{project}-##{event.subject_id}: #{meta['title']}"
    when "issue.moved"
      "#{actor} moved #{meta['project_slug']}-##{event.subject_id} from #{meta['from']&.humanize} to #{meta['to']&.humanize}"
    when "issue.assigned"
      "#{actor} assigned #{meta['project_slug']}-##{event.subject_id} to #{meta['assignee_email']}"
    when "comment.created"
      "#{actor} commented on #{meta['project_slug']}-##{meta['issue_number']}: #{meta['issue_title']}"
    when "project.created"
      "#{actor} created project #{meta['name']}"
    when "membership.created"
      "#{meta['email']} joined as #{meta['role']}"
    when "invitation.created"
      "#{actor} invited #{meta['email']} as #{meta['role']}"
    else
      "#{actor} performed #{event.action}"
    end
  end
end
