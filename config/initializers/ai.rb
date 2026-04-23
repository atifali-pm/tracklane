# Central AI config. Bring-your-own-key: if ANTHROPIC_API_KEY is absent,
# AI features degrade gracefully (no enqueue, no UI suggestion cards) so
# the app still runs fine without internet or credentials. This matches
# the Phase 6 brief: AI is first-class when enabled and silent otherwise.
Rails.application.config.x.ai = ActiveSupport::OrderedOptions.new
Rails.application.config.x.ai.enabled = ENV["ANTHROPIC_API_KEY"].present?
Rails.application.config.x.ai.api_key = ENV["ANTHROPIC_API_KEY"]
Rails.application.config.x.ai.model = ENV.fetch("ANTHROPIC_MODEL", "claude-sonnet-4-5")
