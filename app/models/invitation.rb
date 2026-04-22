class Invitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User"

  enum :role, { admin: 0, manager: 1, member: 2, viewer: 3 }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :email_not_already_member, on: :create

  before_validation :normalize_email
  before_validation :assign_token, on: :create
  before_validation :assign_expiry, on: :create

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }

  def to_param = token

  def pending?
    accepted_at.nil? && expires_at > Time.current
  end

  def accept!(user)
    raise ArgumentError, "Email does not match invitation" unless user.email_address == email

    transaction do
      Membership.find_or_create_by!(user: user, organization: organization) { |m| m.role = role }
      update!(accepted_at: Time.current)
    end
  end

  private
    def normalize_email
      self.email = email.to_s.strip.downcase
    end

    def assign_token
      self.token ||= SecureRandom.urlsafe_base64(32)
    end

    def assign_expiry
      self.expires_at ||= 7.days.from_now
    end

    def email_not_already_member
      return if organization.blank? || email.blank?
      existing_user = User.find_by(email_address: email)
      return unless existing_user && Membership.exists?(user: existing_user, organization: organization)
      errors.add(:email, "is already a member of this organization")
    end
end
