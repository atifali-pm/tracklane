class ApplicationController < ActionController::Base
  include Authentication
  include TenantScoping
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def require_role(*roles)
      allowed = roles.map(&:to_s)
      return if allowed.include?(current_membership&.role&.to_s)

      redirect_to root_path, alert: "You don't have permission to do that."
    end
end
