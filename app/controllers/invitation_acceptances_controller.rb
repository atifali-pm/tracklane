class InvitationAcceptancesController < ApplicationController
  # Public: anyone with the token can see the invitation. Accepting requires
  # the signed-in user's email to match the invited email.
  allow_unauthenticated_access only: :show

  before_action :set_invitation

  def show
  end

  def create
    unless Current.user
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, alert: "Sign in with #{@invitation.email} to accept this invitation."
      return
    end

    unless Current.user.email_address == @invitation.email
      redirect_to invitation_acceptance_path(@invitation.token),
        alert: "You are signed in as #{Current.user.email_address}. Sign out and sign in as #{@invitation.email} to accept."
      return
    end

    # Override the tenant GUC for the rest of this request so the Membership
    # INSERT (and invitation UPDATE) pass RLS WITH CHECK against the
    # invitation's org, not whatever org was in session.
    ApplicationRecord.connection.execute(
      "SET LOCAL app.current_organization_id = #{@invitation.organization_id.to_i}"
    )
    @invitation.accept!(Current.user)
    session[:current_organization_id] = @invitation.organization_id
    redirect_to root_path, notice: "You joined #{@invitation.organization.name} as #{@invitation.role}."
  end

  private
    def set_invitation
      # RLS allows SELECT on invitations for anyone (see CreateInvitations
      # migration): the 32-byte token IS the capability, so finding one by
      # token from outside the inviting org is safe.
      invite = Invitation.find_by(token: params[:token])
      @invitation = invite if invite&.pending?

      return if @invitation
      render plain: "Invitation not found or no longer valid.", status: :not_found
    end
end
