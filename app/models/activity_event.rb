class ActivityEvent < ApplicationRecord
  belongs_to :organization
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true

  validates :action, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  after_create_commit :broadcast_to_feed

  private
    # after_commit runs after the outer transaction has closed, so GUCs are
    # gone. Scope just the partial render so it can pass RLS, and restore
    # the previous GUC state so nothing leaks to enclosing contexts.
    def broadcast_to_feed
      self.class.send(:with_organization_guc, organization_id) do
        Turbo::StreamsChannel.broadcast_prepend_to(
          [ organization, :activity ],
          target: "activity_feed",
          partial: "activity_events/event",
          locals: { event: self }
        )
      end
    end

  # Central emitter used by model callbacks. Wraps the INSERT in its own
  # transaction + SET LOCAL so it works whether or not the caller's request
  # transaction is still open. after_commit callbacks on other models fire
  # AFTER the outer transaction has committed, at which point SET LOCAL
  # settings have already been reset — so we can't rely on the caller's
  # GUCs to still be in place when we try to write.
  def self.record!(action, subject:, actor: Current.user, metadata: {})
    org = Current.organization
    return unless org

    with_organization_guc(org.id) do
      create!(
        organization: org,
        actor: actor,
        action: action.to_s,
        subject_type: subject.class.polymorphic_name,
        subject_id: subject.id,
        metadata: metadata
      )
    end
  end

  # Ensures the INSERT passes RLS even when called from a context where
  # app.current_organization_id is not already set (e.g. after_commit fired
  # on a no-longer-open outer transaction). Restores the previous GUC on
  # exit so the change does not leak into any enclosing transaction, which
  # matters for tests where fixtures and assertions share one outer txn.
  def self.with_organization_guc(id)
    conn = ApplicationRecord.connection
    ApplicationRecord.transaction do
      previous = conn.select_value("SELECT current_setting('app.current_organization_id', true)")
      conn.execute("SET LOCAL app.current_organization_id = #{id.to_i}")
      begin
        yield
      ensure
        if previous.blank?
          conn.execute("RESET app.current_organization_id")
        else
          conn.execute("SET LOCAL app.current_organization_id = #{previous.to_i}")
        end
      end
    end
  end
  private_class_method :with_organization_guc
end
