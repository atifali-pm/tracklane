module ThemesHelper
  # Returns the user's saved preference ("system", "light", or "dark"),
  # or "system" when no user is signed in (auth pages). The inline
  # resolver script in the layout flips "system" to the actual OS
  # preference before the stylesheet applies.
  def theme_preference
    Current.user&.theme.presence || "system"
  end
end
