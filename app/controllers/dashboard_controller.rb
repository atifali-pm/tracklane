class DashboardController < ApplicationController
  def index
    @memberships = Current.user.memberships.includes(:organization)
    @recent_projects = Project.ordered.limit(5) if current_organization
  end
end
