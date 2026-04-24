module ApplicationHelper
  def greeting
    hour = Time.current.hour
    case hour
    when 5..11  then "Good morning"
    when 12..17 then "Good afternoon"
    else             "Good evening"
    end
  end
end
