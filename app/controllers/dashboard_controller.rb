class DashboardController < ApplicationController
  def index
    @memberships = Current.user.memberships.includes(:organization)
  end
end
