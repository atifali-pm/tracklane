class TimeEntry < ApplicationRecord
  belongs_to :organization
  belongs_to :issue
  belongs_to :user

  validates :minutes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 60 * 24 }
  validates :occurred_on, presence: true
  validates :note, length: { maximum: 500 }

  before_validation :assign_organization, on: :create
  after_create_commit :record_logged_event

  scope :ordered, -> { order(occurred_on: :desc, created_at: :desc) }
  scope :for_week_of, ->(date) { where(occurred_on: date.beginning_of_week..date.end_of_week) }

  def self.sum_minutes
    sum(:minutes).to_i
  end

  private
    def assign_organization
      self.organization ||= issue&.organization
    end

    def record_logged_event
      ActivityEvent.record!("time.logged", subject: issue,
        metadata: {
          project_slug: issue.project.slug,
          issue_number: issue.number,
          issue_title: issue.title,
          minutes: minutes,
          occurred_on: occurred_on.iso8601
        })
    end
end
