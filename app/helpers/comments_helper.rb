module CommentsHelper
  def highlight_mentions(body)
    safe_body = h(body.to_s)
    safe_body.gsub(Comment::MENTION_PATTERN) do
      email = Regexp.last_match(1)
      %(<span class="text-blue-700 font-medium">@#{h(email)}</span>)
    end.html_safe
  end
end
