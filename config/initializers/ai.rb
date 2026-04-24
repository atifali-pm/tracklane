# Central AI config. Bring-your-own-key: if ANTHROPIC_API_KEY is absent,
# AI features degrade gracefully (no enqueue, no UI suggestion cards) so
# the app still runs fine without internet or credentials. This matches
# the Phase 6 brief: AI is first-class when enabled and silent otherwise.
Rails.application.config.x.ai = ActiveSupport::OrderedOptions.new
Rails.application.config.x.ai.enabled = ENV["ANTHROPIC_API_KEY"].present?
Rails.application.config.x.ai.api_key = ENV["ANTHROPIC_API_KEY"]
Rails.application.config.x.ai.model = ENV.fetch("ANTHROPIC_MODEL", "claude-sonnet-4-5")

# Embeddings provider (BYOK via OPENAI_API_KEY). text-embedding-3-small is
# 1536 dims, which matches the vector(1536) column on document_chunks. When
# no key is set, RAG features silently degrade like the triage flag.
Rails.application.config.x.embeddings = ActiveSupport::OrderedOptions.new
Rails.application.config.x.embeddings.enabled = ENV["OPENAI_API_KEY"].present?
Rails.application.config.x.embeddings.api_key = ENV["OPENAI_API_KEY"]
Rails.application.config.x.embeddings.model = ENV.fetch("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")
