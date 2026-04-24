module ProjectAsksHelper
  # Turns inline citations like [acme-mobile-#12] or [acme-mobile-#12 comment]
  # into real links to the underlying issue page, and safely escapes everything
  # else.
  def answer_with_links(text, project)
    safe = h(text.to_s)
    safe.gsub(/\[(#{Regexp.escape(project.slug)})-#(\d+)(?:\s+comment)?\]/i) do
      number = Regexp.last_match(2)
      path = project_issue_path(project.slug, number)
      %(<a href="#{path}" class="text-indigo-600 dark:text-indigo-300 hover:underline">#{Regexp.last_match(0)}</a>)
    end.html_safe
  end
end
