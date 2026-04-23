class ActivityEventsController < ApplicationController
  before_action :require_current_organization

  def index
    @events = current_organization.activity_events.ordered.limit(100)
  end

  private
    def require_current_organization
      return if current_organization
      redirect_to root_path, alert: "Pick an organization first."
    end
end
