class ProjectTemplate
  TEMPLATES = {
    "software" => {
      label: "Software team",
      description: "Typical engineering project with a backlog, review column, and done.",
      starter_issues: [
        { title: "Set up CI pipeline",         priority: "high",   status: "open" },
        { title: "Define coding standards",    priority: "medium", status: "open" },
        { title: "Write onboarding guide",     priority: "low",    status: "open" },
        { title: "Add error monitoring",       priority: "high",   status: "open" }
      ]
    },
    "marketing" => {
      label: "Marketing campaign",
      description: "Creative and distribution tasks for a launch campaign.",
      starter_issues: [
        { title: "Draft campaign brief",       priority: "urgent", status: "open" },
        { title: "Produce launch video",       priority: "high",   status: "open" },
        { title: "Schedule social calendar",   priority: "medium", status: "open" },
        { title: "Line up press outreach",     priority: "medium", status: "open" }
      ]
    },
    "personal" => {
      label: "Personal workspace",
      description: "Single-owner list for personal tasks and ideas.",
      starter_issues: [
        { title: "Inbox zero",                 priority: "medium", status: "open" },
        { title: "Weekly review",              priority: "low",    status: "open" }
      ]
    }
  }.freeze

  def self.all
    TEMPLATES
  end

  def self.fetch(key)
    TEMPLATES[key.to_s]
  end

  def self.apply!(key, project, reporter:)
    template = fetch(key)
    return unless template
    template[:starter_issues].each do |attrs|
      project.issues.create!(
        reporter: reporter,
        title: attrs[:title],
        priority: attrs[:priority],
        status: attrs[:status]
      )
    end
  end
end
