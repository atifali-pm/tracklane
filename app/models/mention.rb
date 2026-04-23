class Mention < ApplicationRecord
  belongs_to :comment
  belongs_to :user
  belongs_to :organization

  after_create_commit :deliver_notification

  private
    # Skip self-mentions; no point emailing the commenter their own message.
    def deliver_notification
      return if user_id == comment.user_id
      NotificationMailer.mentioned(user_id: user_id, comment_id: comment_id).deliver_later
    end
end
