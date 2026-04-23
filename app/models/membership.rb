class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { admin: 0, manager: 1, member: 2, viewer: 3 }

  validates :user_id, uniqueness: { scope: :organization_id }

  after_create_commit :record_joined_event

  private
    def record_joined_event
      ActivityEvent.record!("membership.created", subject: self,
        metadata: { email: user.email_address, role: role })
    end
end
