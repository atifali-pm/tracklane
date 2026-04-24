module TimeEntriesHelper
  # "135" -> "2h 15m", "45" -> "45m", "480" -> "8h"
  def format_minutes(total_minutes)
    return "0m" if total_minutes.to_i <= 0
    hours, minutes = total_minutes.to_i.divmod(60)
    parts = []
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0
    parts.join(" ")
  end
end
