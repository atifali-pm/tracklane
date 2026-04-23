class NotificationMailer < ApplicationMailer
  # Sent when a user is @mentioned in a comment on an issue they do not own.
  def mentioned(user_id:, comment_id:)
    @comment = Comment.find_by(id: comment_id)
    @recipient = User.find_by(id: user_id)
    return if @comment.nil? || @recipient.nil?

    @issue = @comment.issue
    @project = @issue.project
    @organization = @comment.organization

    mail(
      to: @recipient.email_address,
      subject: "[#{@organization.name}] You were mentioned on #{@project.slug}-##{@issue.number}"
    )
  end

  # Sent when an issue gains a new assignee (or switches assignee).
  def assigned(issue_id:)
    @issue = Issue.find_by(id: issue_id)
    return if @issue.nil? || @issue.assignee.nil?

    @project = @issue.project
    @organization = @issue.organization
    @recipient = @issue.assignee

    mail(
      to: @recipient.email_address,
      subject: "[#{@organization.name}] You were assigned #{@project.slug}-##{@issue.number}"
    )
  end

  # Sent when an admin creates a pending invitation.
  def invited(invitation_id:)
    @invitation = Invitation.find_by(id: invitation_id)
    return if @invitation.nil? || @invitation.accepted_at.present?

    @organization = @invitation.organization
    @inviter = @invitation.invited_by
    @accept_url = Rails.application.routes.url_helpers.invitation_acceptance_url(
      token: @invitation.token,
      host: ENV.fetch("TRACKLANE_HOST", "localhost"),
      port: ENV.fetch("TRACKLANE_PORT", 8020)
    )

    mail(
      to: @invitation.email,
      subject: "You are invited to #{@organization.name} on Tracklane"
    )
  end
end
