import { Controller } from "@hotwired/stimulus"

// Instant client-side theme flip + background persist.
//
// Problem: Turbo preserves <html> across visits, so letting the server
// re-render with a new data-theme needs a full reload. That feels janky.
// Fix: mutate documentElement.dataset.theme locally the moment the user
// clicks, then fire-and-forget a PATCH to /user_preferences to persist
// the choice. The next cold page load will render with the saved value.
export default class extends Controller {
  static targets = ["icon"]
  static values = { url: String, token: String }

  toggle(event) {
    event.preventDefault()
    const current = document.documentElement.dataset.theme
    const next = current === "dark" ? "light" : "dark"

    document.documentElement.dataset.theme = next
    if (this.hasIconTarget) {
      this.iconTarget.textContent = next === "dark" ? "☀" : "☾"
    }

    fetch(`${this.urlValue}?theme=${next}`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.tokenValue,
        "Accept": "text/html"
      },
      credentials: "same-origin"
    }).catch(() => {
      // If the persist fails we don't undo the client flip; the user will
      // see the chosen theme this session, and the next cold load will
      // re-read whatever the server has. Worst case they click again.
    })
  }
}
