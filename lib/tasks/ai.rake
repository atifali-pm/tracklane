namespace :ai do
  desc "Enqueue embedding jobs for every existing Project / Issue / Comment"
  task embed_backfill: :environment do
    unless EmbeddingService.enabled?
      puts "OPENAI_API_KEY not set; set it and re-run to backfill embeddings."
      next
    end

    # We run as the tracklane owner (via bin/db rake) so RLS is bypassed
    # here and we can iterate every tenant-scoped record.
    total = 0

    Organization.find_each do |org|
      Issue.unscoped.where(organization_id: org.id).pluck(:id).each do |id|
        EmbedDocumentJob.perform_later("Issue", id, org.id)
        total += 1
      end

      Comment.unscoped.where(organization_id: org.id).pluck(:id).each do |id|
        EmbedDocumentJob.perform_later("Comment", id, org.id)
        total += 1
      end

      Project.unscoped.where(organization_id: org.id).pluck(:id).each do |id|
        EmbedDocumentJob.perform_later("Project", id, org.id)
        total += 1
      end
    end

    puts "Enqueued #{total} EmbedDocumentJob records."
  end
end
