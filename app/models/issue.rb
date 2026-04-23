class Issue < ApplicationRecord
  belongs_to :project
  belongs_to :organization
  belongs_to :reporter, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  enum :status,   { open: 0, in_progress: 1, in_review: 2, done: 3, blocked: 4 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 10_000 }
  validates :number, presence: true, uniqueness: { scope: :project_id }

  before_validation :assign_organization, on: :create
  before_validation :assign_number, on: :create
  validate :assignee_belongs_to_same_organization

  scope :ordered, -> { order(created_at: :desc) }
  scope :open_issues, -> { where(status: %i[open in_progress in_review blocked]) }

  after_update_commit :broadcast_board_update, if: :saved_change_to_status?

  def to_param = number.to_s

  def reference
    "#{project.slug}-##{number}"
  end

  private
    def assign_organization
      self.organization ||= project&.organization
    end

    def assign_number
      return if number.present? || project.blank?
      # Atomic bump via UPDATE ... RETURNING so concurrent issue creates in
      # the same project don't collide on the (project_id, number) unique index.
      row = self.class.connection.select_one(
        "UPDATE projects SET issues_counter = issues_counter + 1 WHERE id = #{project.id.to_i} RETURNING issues_counter"
      )
      self.number = row["issues_counter"]
    end

    def assignee_belongs_to_same_organization
      return if assignee.blank? || organization.blank?
      return if Membership.exists?(user_id: assignee_id, organization_id: organization_id)
      errors.add(:assignee, "must be a member of the project's organization")
    end

    # Re-renders the two affected columns (old + new status) on the project's
    # board stream whenever an issue status changes. Runs inside the request
    # transaction so the RLS GUCs are still set when the partials query for
    # their sibling issues.
    def broadcast_board_update
      from_status, to_status = saved_change_to_status
      [ from_status, to_status ].compact.uniq.each do |status|
        Turbo::StreamsChannel.broadcast_replace_to(
          [ project, :board ],
          target: "board_column_#{status}_list",
          partial: "boards/column_list",
          locals: { project: project, issues: project.issues.where(status: status).ordered, status: status }
        )
      end
    end
end
