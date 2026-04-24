class ProjectAskService
  class NotEnabledError < StandardError; end

  TOP_K = 6
  SYSTEM_PROMPT = <<~SYSTEM.freeze
    You answer questions about a specific software project inside Tracklane.
    You are given the user's question plus a small set of retrieved context
    chunks from that project's issues, comments, and description.

    Rules:
      - Only answer using information that appears in the provided chunks.
      - If the chunks do not contain the answer, say you do not have enough
        information and suggest what the user could add to help.
      - Keep answers concise (usually 2 to 6 sentences or a short list).
      - When you reference a specific issue or comment, cite it as
        `[project-slug-#N]` or `[project-slug-#N comment]` exactly, matching
        the markers in the context block. The UI will turn these into links.
  SYSTEM

  # Ask needs both a chat provider (config.x.ai) and an embeddings provider
  # (config.x.embeddings). It intentionally does NOT pass through
  # IssueTriageService.enabled? so the two AI features are independent.
  def self.enabled?
    Rails.application.config.x.ai.enabled && EmbeddingService.enabled?
  end

  def initialize(project, question, anthropic: nil)
    @project = project
    @question = question.to_s.strip
    @anthropic = anthropic
  end

  def call
    raise NotEnabledError unless self.class.enabled?
    return { answer: "Please enter a question.", chunks: [] } if @question.empty?

    chunks = retrieve_chunks
    if chunks.empty?
      return {
        answer: "No indexed content yet for this project. Run `bin/rails ai:embed_backfill` once the OPENAI_API_KEY is set, or create some issues first.",
        chunks: []
      }
    end

    answer = ask_claude(chunks)
    { answer: answer, chunks: chunks }
  end

  private
    def retrieve_chunks
      query_embedding = EmbeddingService.embed(@question)
      return [] if query_embedding.blank?

      DocumentChunk
        .where(organization_id: @project.organization_id)
        .where("metadata->>'project_slug' = :slug OR (source_type = 'Project' AND source_id = :pid)",
               slug: @project.slug, pid: @project.id)
        .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
        .first(TOP_K)
    end

    def ask_claude(chunks)
      context = chunks.each_with_index.map do |chunk, i|
        marker = chunk_marker(chunk)
        "[#{i + 1}] #{marker}\n#{chunk.content}"
      end.join("\n\n---\n\n")

      user_prompt = <<~PROMPT
        Project: #{@project.name} (slug #{@project.slug})

        Retrieved context (#{chunks.size} chunks, most relevant first):

        #{context}

        Question: #{@question}
      PROMPT

      response = client.messages.create(
        model: Rails.application.config.x.ai.model,
        max_tokens: 700,
        system: [ { type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } } ],
        messages: [ { role: "user", content: user_prompt } ]
      )

      Array(response.content).select { |b| b.type == :text }.map(&:text).join
    end

    def client
      @client ||= (@anthropic || Anthropic::Client.new(api_key: Rails.application.config.x.ai.api_key))
    end

    def chunk_marker(chunk)
      meta = chunk.metadata || {}
      case meta["kind"]
      when "issue"
        "[#{meta['project_slug']}-##{meta['number']}]"
      when "comment"
        "[#{meta['project_slug']}-##{meta['issue_number']} comment]"
      when "project"
        "[#{meta['slug']} (project)]"
      else
        "[chunk]"
      end
    end
end
