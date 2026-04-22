class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { admin: 0, manager: 1, member: 2, viewer: 3 }

  validates :user_id, uniqueness: { scope: :organization_id }
end
