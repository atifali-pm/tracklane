class Issue < ApplicationRecord
  belongs_to :project
  belongs_to :organization
  belongs_to :reporter, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy
  has_many :time_entries, dependent: :destroy

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

  after_create_commit  :record_opened_event
  after_create_commit  :enqueue_triage, if: -> { IssueTriageService.enabled? }
  after_commit :enqueue_embedding, on: %i[create update], if: -> { EmbeddingService.enabled? }
  after_update_commit  :broadcast_board_update, if: :saved_change_to_status?
  after_update_commit  :record_moved_event,     if: :saved_change_to_status?
  after_update_commit  :record_assigned_event,  if: :saved_change_to_assignee_id?

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

    def record_opened_event
      ActivityEvent.record!("issue.opened", subject: self, metadata: { project_slug: project.slug, title: title })
    end

    def enqueue_triage
      IssueTriageJob.perform_later(id, organization_id)
    end

    def enqueue_embedding
      EmbedDocumentJob.perform_later("Issue", id, organization_id)
    end

    def record_moved_event
      from, to = saved_change_to_status
      ActivityEvent.record!("issue.moved", subject: self,
        metadata: { project_slug: project.slug, from: from, to: to, title: title })
    end

    def record_assigned_event
      return if assignee_id.blank?
      ActivityEvent.record!("issue.assigned", subject: self,
        metadata: { project_slug: project.slug, title: title, assignee_email: assignee&.email_address })

      # Only notify the assignee when it is someone other than the person
      # who just changed the issue (otherwise self-assignments spam the box).
      return if Current.user && Current.user.id == assignee_id
      NotificationMailer.assigned(issue_id: id).deliver_later
    end

    # Re-renders the two affected columns (old + new status) on the project's
    # board stream whenever an issue status changes. after_update_commit
    # fires AFTER the outer request transaction has committed (so SET LOCAL
    # settings are gone). Open a fresh transaction and re-apply the GUC so
    # the partial's DB queries pass RLS; the org id is read from the record
    # itself rather than Current, which may not be set for background paths.
    def broadcast_board_update
      from_status, to_status = saved_change_to_status
      statuses = [ from_status, to_status ].compact.uniq

      ActivityEvent.with_organization_guc(organization_id) do
        statuses.each do |status|
          Turbo::StreamsChannel.broadcast_replace_to(
            [ project, :board ],
            target: "board_column_#{status}_list",
            partial: "boards/column_list",
            locals: { project: project, issues: project.issues.where(status: status).ordered, status: status }
          )
        end
      end
    end
end
