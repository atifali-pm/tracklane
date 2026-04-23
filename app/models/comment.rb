class Comment < ApplicationRecord
  MENTION_PATTERN = /@([\w.+-]+@[\w.-]+\.\w+)/

  belongs_to :issue
  belongs_to :user
  belongs_to :organization
  has_many :mentions, dependent: :destroy
  has_many :mentioned_users, through: :mentions, source: :user

  validates :body, presence: true, length: { maximum: 10_000 }

  before_validation :assign_organization, on: :create
  after_create :extract_mentions
  after_create_commit :record_created_event

  scope :ordered, -> { order(created_at: :asc) }

  private
    def assign_organization
      self.organization ||= issue&.organization
    end

    def record_created_event
      ActivityEvent.record!("comment.created", subject: self,
        metadata: { project_slug: issue.project.slug, issue_number: issue.number, issue_title: issue.title })
    end

    def extract_mentions
      return if body.blank?

      emails = body.scan(MENTION_PATTERN).flatten.map(&:downcase).uniq
      return if emails.empty?

      # Only mention users who are members of the current org. Membership
      # lookup is already tenant-scoped by RLS.
      User.where(email_address: emails).find_each do |user|
        next unless Membership.exists?(user_id: user.id, organization_id: organization_id)
        Mention.find_or_create_by(comment_id: id, user_id: user.id, organization_id: organization_id)
      end
    end
end
