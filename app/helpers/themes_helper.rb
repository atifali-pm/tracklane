module ThemesHelper
  # Renders one of "light" or "dark" so CSS has a single attribute to key off.
  # "system" defaults to light here because detecting OS scheme server-side
  # is not possible without JS. A tiny script in the nav can flip to dark
  # client-side if prefers-color-scheme says so; that is a future polish.
  def resolved_theme
    case Current.user&.theme
    when "dark" then "dark"
    when "light" then "light"
    else "light"
    end
  end

  def theme_preference
    Current.user&.theme.presence || "system"
  end
end
