module WikiPagesHelper
  # Render a trusted-user markdown string to HTML. kramdown handles the
  # parse + the syntax highlighting of fenced code blocks. GFM input parser
  # adds tables, strikethrough, task lists.
  def markdown(source)
    return "".html_safe if source.blank?
    Kramdown::Document.new(
      source.to_s,
      input: "GFM",
      hard_wrap: false,
      syntax_highlighter: nil
    ).to_html.html_safe
  end
end
