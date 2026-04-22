class CurrentOrganizationsController < ApplicationController
  def update
    org = Current.user.organizations.find_by(slug: params[:slug])

    if org
      session[:current_organization_id] = org.id
      redirect_back fallback_location: root_path, notice: "Switched to #{org.name}."
    else
      redirect_back fallback_location: root_path, alert: "You are not a member of that organization."
    end
  end
end
