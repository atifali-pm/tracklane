class IssueTriageService
  class NotEnabledError < StandardError; end

  SYSTEM_PROMPT = <<~SYSTEM.freeze
    You triage newly opened issues in a multi-tenant project management tool called Tracklane.

    Given an issue's title, description, and the list of organization members with their roles, pick:
      - a priority from: low, medium, high, urgent
      - an assignee email from the provided members (must match exactly) OR null when no assignee is obvious
      - up to 3 short lowercase tag-style labels (e.g. "bug", "design", "backend", "accessibility")
      - a one sentence rationale describing why you chose the priority and assignee

    Prefer assigning to managers when the issue looks cross-cutting, members when the scope is clear
    and bounded, and return null rather than guessing when signal is weak. Only suggest urgent when
    the description clearly mentions production impact, security, or data loss.

    Always respond by calling the `suggest_triage` tool exactly once.
  SYSTEM

  TRIAGE_TOOL = {
    name: "suggest_triage",
    description: "Record triage suggestions for an issue.",
    input_schema: {
      type: "object",
      properties: {
        priority: {
          type: "string",
          enum: %w[low medium high urgent]
        },
        assignee_email: {
          type: [ "string", "null" ],
          description: "Must exactly match a provided member email, or null."
        },
        labels: {
          type: "array",
          items: { type: "string" },
          maxItems: 3
        },
        rationale: {
          type: "string"
        }
      },
      required: %w[priority labels rationale]
    }
  }.freeze

  def self.enabled?
    Rails.application.config.x.ai.enabled
  end

  def initialize(issue, client: nil)
    @issue = issue
    @client = client
  end

  def call
    raise NotEnabledError unless self.class.enabled?

    response = client.messages.create(
      model: Rails.application.config.x.ai.model,
      max_tokens: 512,
      tools: [ TRIAGE_TOOL ],
      tool_choice: { type: "tool", name: TRIAGE_TOOL[:name] },
      system: [ { type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } } ],
      messages: [ { role: "user", content: user_prompt } ]
    )

    extract_suggestion(response)
  end

  private
    attr_reader :issue

    def client
      @client ||= Anthropic::Client.new(api_key: Rails.application.config.x.ai.api_key)
    end

    def user_prompt
      members_block = issue.organization.users.order(:email_address).map do |user|
        role = Membership.find_by(user_id: user.id, organization_id: issue.organization_id)&.role
        "  - #{user.email_address} (#{role})"
      end.join("\n")

      <<~PROMPT
        Project: #{issue.project.name}
        Organization: #{issue.organization.name}

        New issue:
        Title: #{issue.title}
        Description: #{issue.description.to_s.strip.empty? ? '(no description provided)' : issue.description}

        Organization members:
        #{members_block}

        Call the suggest_triage tool with your recommendation.
      PROMPT
    end

    def extract_suggestion(response)
      tool_use = Array(response.content).find { |block| block.type == :tool_use }
      raise "Claude did not return a tool_use block" unless tool_use

      data = tool_use.input.deep_stringify_keys
      {
        "priority"       => data["priority"],
        "assignee_email" => data["assignee_email"].presence,
        "labels"         => Array(data["labels"]).first(3),
        "rationale"      => data["rationale"],
        "model"          => Rails.application.config.x.ai.model,
        "generated_at"   => Time.current.iso8601
      }
    end
end
