class IssueTemplate
  TEMPLATES = {
    "bug" => {
      label: "Bug report",
      body: <<~MD
        ## What happened

        (A clear description of the bug.)

        ## Steps to reproduce

        1.
        2.
        3.

        ## Expected behavior

        (What you expected to happen.)

        ## Environment

        - Browser:
        - OS:
        - App version:
      MD
    },
    "feature" => {
      label: "Feature request",
      body: <<~MD
        ## Problem

        (What user problem does this solve?)

        ## Proposed solution

        (What would the ideal solution look like?)

        ## Alternatives considered

        (Other options you ruled out and why.)

        ## Success criteria

        - [ ]
        - [ ]
      MD
    },
    "task" => {
      label: "Task",
      body: <<~MD
        ## Context

        (Why is this task needed?)

        ## Acceptance criteria

        - [ ]
        - [ ]

        ## Notes

      MD
    }
  }.freeze

  def self.all
    TEMPLATES
  end

  def self.body_for(key)
    TEMPLATES.dig(key.to_s, :body)
  end
end
