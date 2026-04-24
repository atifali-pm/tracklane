class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :reported_issues, class_name: "Issue", foreign_key: :reporter_id, dependent: :nullify
  has_many :assigned_issues, class_name: "Issue", foreign_key: :assignee_id, dependent: :nullify
  has_many :time_entries, dependent: :destroy

  THEMES = %w[system light dark].freeze

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :theme, inclusion: { in: THEMES }
end
