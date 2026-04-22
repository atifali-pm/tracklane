class InvitationsController < ApplicationController
  before_action :require_current_organization
  before_action -> { require_role(:admin) }

  def index
    @pending = current_organization.invitations.pending.includes(:invited_by).order(created_at: :desc)
  end

  def new
    @invitation = current_organization.invitations.build
  end

  def create
    @invitation = current_organization.invitations.build(invitation_params)
    @invitation.invited_by = Current.user

    if @invitation.save
      redirect_to invitations_path, notice: "Invitation created. Share the link below with #{@invitation.email}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    invitation = current_organization.invitations.find_by!(token: params[:id])
    invitation.destroy
    redirect_to invitations_path, notice: "Invitation revoked."
  end

  private
    def require_current_organization
      return if current_organization
      redirect_to root_path, alert: "Pick an organization first."
    end

    def invitation_params
      params.expect(invitation: %i[email role])
    end
end
