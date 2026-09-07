---
published: false
---
# Newsletter archive

One file per sent issue. The filename is the URL: `2026-09-milkman-zero.html` -> `/newsletter/2026-09-milkman-zero`.

```
---
layout: newsletter-issue
title: "MILKMAN ZERO opens in December"
date: 2026-09-08
subject: "MILKMAN ZERO opens in December (and this is my first newsletter)"
---
<!-- paste everything between <body> and </body> of the sent email here -->
```

Optional fields that feed the NEWSLETTER and COMING UP rows on `/info`:

```
excerpt_text: "One or two sentences shown under the title on the info page."
preview: /assets/images/newsletter/milkman-zero-logo.png   # image for the card (hidden while the same show is in COMING UP)
show:                       # adds a COMING UP / ON NOW row until last_date passes
  title: MILKMAN ZERO
  dates: "December 3–13, 2026"
  venue: "MITU580, Brooklyn"
  first_date: 2026-12-03
  last_date: 2026-12-13
  tickets: https://milkmanzero.com
  logo: /assets/images/newsletter/milkman-zero-logo.png   # optional; falls back to preview
```

Two edits to the pasted HTML:

1. Delete the `<a href="{{ unsubscribe }}">Unsubscribe</a>` line in the footer. Jekyll treats the braces as a template tag. (The layout hides any empty link as a fallback, but delete it anyway.)
2. Confirm every image `src` points at `https://matt-romein.com/assets/images/newsletter/...`, not a Brevo URL.

Archive only after the issue has sent, with placeholders filled, so the page matches what people received.
