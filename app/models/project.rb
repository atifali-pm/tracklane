class Project < ApplicationRecord
  belongs_to :organization
  has_many :issues, dependent: :destroy

  enum :status, { active: 0, archived: 1 }

  validates :name, presence: true, length: { maximum: 120 }
  validates :slug, presence: true,
    uniqueness: { scope: :organization_id },
    format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and dashes" }
  validates :description, length: { maximum: 2_000 }

  before_validation :generate_slug, on: :create

  scope :ordered, -> { order(:name) }

  def to_param = slug

  private
    def generate_slug
      return if slug.present? || name.blank?
      self.slug = name.parameterize
    end
end
