# Follow-up recommendations

The migration intentionally keeps the published site's appearance and behavior close to the
current version. These optional items are for a later review and have not been changed as part
of the migration:

- **Audit keyboard focus and the dark-mode toggle.** The current toggle is a checkbox hidden
  with `display: none` and styled as a switch. Check keyboard operation and visible focus
  treatment; consider a visually-hidden checkbox with a clear focus indicator.
- **Review contrast in both themes.** Measure text, link, and switch-state contrast against
  WCAG 2.2 AA, especially for muted text and decorative controls.
- **Clarify decorative and interactive graphics.** Confirm the logo is announced as intended
  by screen readers; if it is purely decorative, mark the SVG as hidden from assistive
  technology.
- **Add automated accessibility checks.** Run an accessibility scan on the home, about, post
  listing, and representative article pages, then verify findings manually.
- **Consider a publishing preview.** A pull-request workflow that builds and uploads a
  preview artifact would let you review content and links before merging to `main`.
