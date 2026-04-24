require "net/http"
require "uri"
require "json"

class EmbeddingService
  class NotEnabledError < StandardError; end
  class ApiError < StandardError; end

  OPENAI_URL = URI("https://api.openai.com/v1/embeddings")

  def self.enabled?
    Rails.application.config.x.embeddings.enabled
  end

  # Returns a [Float] of the configured dimensionality (1536 for
  # text-embedding-3-small). Input is a single string; no batching yet
  # since Tracklane embeds one chunk per record.
  def self.embed(text)
    raise NotEnabledError unless enabled?

    body = {
      model: Rails.application.config.x.embeddings.model,
      input: text.to_s.slice(0, 8000)
    }

    req = Net::HTTP::Post.new(OPENAI_URL)
    req["Authorization"] = "Bearer #{Rails.application.config.x.embeddings.api_key}"
    req["Content-Type"]  = "application/json"
    req.body = body.to_json

    response = Net::HTTP.start(OPENAI_URL.hostname, OPENAI_URL.port, use_ssl: true, read_timeout: 30) do |http|
      http.request(req)
    end

    raise ApiError, "OpenAI #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(response.body)
    parsed.dig("data", 0, "embedding")
  end
end
