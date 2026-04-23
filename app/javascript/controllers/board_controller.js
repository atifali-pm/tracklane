import { Controller } from "@hotwired/stimulus"

// Kanban drag-drop: moves issue cards between status columns and PATCHes the
// authoritative change to /projects/:slug/issues/:number/move. The server's
// Turbo Stream broadcast then replaces both affected column contents for all
// subscribers (including the user who dragged), so any cross-user move races
// resolve to whichever write committed last.
export default class extends Controller {
  static targets = ["card", "column", "list"]
  static values = {
    moveUrlTemplate: String,
    csrfToken: String,
    draggable: Boolean
  }

  connect() {
    if (!this.draggableValue) {
      this.element.querySelectorAll("[draggable=true]").forEach(el => el.setAttribute("draggable", "false"))
      return
    }

    this.boundDragStart = this.onDragStart.bind(this)
    this.boundDragOver  = this.onDragOver.bind(this)
    this.boundDrop      = this.onDrop.bind(this)
    this.boundDragEnd   = this.onDragEnd.bind(this)

    this.element.addEventListener("dragstart", this.boundDragStart)
    this.element.addEventListener("dragover",  this.boundDragOver)
    this.element.addEventListener("drop",      this.boundDrop)
    this.element.addEventListener("dragend",   this.boundDragEnd)
  }

  disconnect() {
    if (!this.draggableValue) return
    this.element.removeEventListener("dragstart", this.boundDragStart)
    this.element.removeEventListener("dragover",  this.boundDragOver)
    this.element.removeEventListener("drop",      this.boundDrop)
    this.element.removeEventListener("dragend",   this.boundDragEnd)
  }

  onDragStart(event) {
    const card = event.target.closest("[data-issue-number]")
    if (!card) return
    this.dragging = card
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", card.dataset.issueNumber)
    card.classList.add("opacity-50")
  }

  onDragOver(event) {
    const list = event.target.closest('[data-board-target="list"]')
    if (!list) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    list.classList.add("ring-2", "ring-blue-300", "dark:ring-blue-700", "ring-inset")
  }

  onDragLeave(event) {
    const list = event.target.closest('[data-board-target="list"]')
    if (list) list.classList.remove("ring-2", "ring-blue-300", "dark:ring-blue-700", "ring-inset")
  }

  onDrop(event) {
    event.preventDefault()
    const list = event.target.closest('[data-board-target="list"]')
    if (!list || !this.dragging) return

    list.classList.remove("ring-2", "ring-blue-300", "dark:ring-blue-700", "ring-inset")

    const newStatus = list.dataset.boardStatusValue
    const issueNumber = this.dragging.dataset.issueNumber

    // Optimistic DOM move; the server broadcast will correct it if needed.
    list.appendChild(this.dragging)

    const url = this.moveUrlTemplateValue.replace("__NUM__", issueNumber)
    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": this.csrfTokenValue
      },
      credentials: "same-origin",
      body: JSON.stringify({ status: newStatus })
    }).catch(() => {
      // Refresh the page if the move fails so the user sees authoritative state.
      window.location.reload()
    })
  }

  onDragEnd() {
    if (this.dragging) this.dragging.classList.remove("opacity-50")
    this.dragging = null
    this.element.querySelectorAll('[data-board-target="list"]').forEach(el => {
      el.classList.remove("ring-2", "ring-blue-300", "dark:ring-blue-700", "ring-inset")
    })
  }
}
