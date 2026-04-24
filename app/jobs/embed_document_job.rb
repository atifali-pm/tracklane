class EmbedDocumentJob < ApplicationJob
  queue_as :default

  discard_on EmbeddingService::NotEnabledError

  # Indexes a single record (Issue / Comment / Project) into document_chunks
  # with an OpenAI embedding. The organization_id is passed in so the job
  # can re-establish the tenant GUC before any SELECT/UPSERT (background
  # workers run outside a request, so TenantScoping isn't in effect).
  def perform(source_type, source_id, organization_id)
    return unless EmbeddingService.enabled?

    ActivityEvent.with_organization_guc(organization_id) do
      record = source_type.constantize.find_by(id: source_id)
      return unless record

      content = build_content(record)
      return if content.blank?

      embedding = EmbeddingService.embed(content)
      return unless embedding

      DocumentChunk.upsert(
        {
          organization_id: organization_id,
          source_type: source_type,
          source_id: source_id,
          content: content,
          embedding: embedding,
          metadata: metadata_for(record),
          created_at: Time.current,
          updated_at: Time.current
        },
        unique_by: %i[source_type source_id]
      )
    end
  rescue EmbeddingService::ApiError => e
    Rails.logger.warn("EmbedDocumentJob API error for #{source_type}##{source_id}: #{e.message}")
    raise if Rails.env.test?
  rescue StandardError => e
    Rails.logger.warn("EmbedDocumentJob failed for #{source_type}##{source_id}: #{e.class}: #{e.message}")
    raise if Rails.env.test?
  end

  private
    def build_content(record)
      case record
      when Issue
        [ "Issue #{record.project.slug}-##{record.number}: #{record.title}", record.description ].compact.join("\n\n")
      when Comment
        [ "Comment on #{record.issue.project.slug}-##{record.issue.number} (#{record.issue.title}) by #{record.user.email_address}:", record.body ].compact.join("\n")
      when Project
        [ "Project #{record.name}", record.description ].compact.join("\n\n")
      end
    end

    def metadata_for(record)
      case record
      when Issue
        { kind: "issue", project_slug: record.project.slug, number: record.number, title: record.title }
      when Comment
        { kind: "comment", project_slug: record.issue.project.slug, issue_number: record.issue.number, issue_title: record.issue.title }
      when Project
        { kind: "project", slug: record.slug, name: record.name }
      else
        {}
      end
    end
end
