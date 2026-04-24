class WikiPage < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :last_editor, class_name: "User", optional: true

  validates :title, presence: true, length: { maximum: 200 }
  validates :body,  length: { maximum: 100_000 }
  validates :slug, presence: true,
    uniqueness: { scope: :project_id },
    format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and dashes" }

  before_validation :assign_organization, on: :create
  before_validation :generate_slug, on: :create
  after_create_commit  :record_created_event
  after_update_commit  :record_updated_event, if: :saved_change_to_body?

  scope :ordered, -> { order(:position, :title) }

  def to_param = slug

  private
    def assign_organization
      self.organization ||= project&.organization
    end

    def generate_slug
      return if slug.present? || title.blank?
      self.slug = title.parameterize
    end

    def record_created_event
      ActivityEvent.record!("wiki.created", subject: self,
        metadata: { project_slug: project.slug, title: title, slug: slug })
    end

    def record_updated_event
      ActivityEvent.record!("wiki.updated", subject: self,
        metadata: { project_slug: project.slug, title: title, slug: slug })
    end
end
