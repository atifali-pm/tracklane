class UserPreferencesController < ApplicationController
  def update
    theme = params[:theme].to_s
    if User::THEMES.include?(theme)
      Current.user.update!(theme: theme)
    end
    redirect_back fallback_location: root_path
  end
end
