# Site speed and project page layout — design

Date: 2026-09-07. Scope: home splash load, individual project/design/experiment pages, shared head/header. Out of scope: the info page (one script tag moves, no design change), CV, teaching, newsletter pages, the menu overlay's look, the desktop nav-hide-on-idle behaviour.

## Goals

1. Home splash shows moving video within about a second on a normal connection.
2. Project pages look cleaner and more unified: credits block reads as one system with the info page, media section is shorter and aligned with the text.
3. Every page downloads a fraction of today's bytes.
4. Nothing ships until Matt reviews locally. No commits or pushes without his say-so.

## Decisions already taken (with Matt)

- Splash clips re-encoded at **1080p, ~4 MB each** (not 720p).
- Media section becomes a **two-up grid**, first item full width.
- Credits block: build **both** variant A (rail) and B (tidy two-column) as real test pages; Matt picks one; the other is deleted.
- The hero video's duplicate at the end of `documentation` is **removed**.

## 1. Home splash

### Assets
- Re-encode `assets/bg_videos/01..09.mp4` with ffmpeg: h264, `-preset slow -crf 23 -maxrate 3500k -bufsize 7000k`, `-pix_fmt yuv420p`, `-g 60 -sc_threshold 0`, `-an` (drops the unused AAC + 640 kbps AC3 tracks), `-movflags +faststart`. All clips stay exactly 1920x1080 (PIXI 4 caches the first video's dimensions).
- New file names `01-1080.mp4` … `09-1080.mp4` so Cloudflare's 5-day cache cannot serve stale copies. Originals move to `_originals/bg_videos/` (kept in the repo, not published: Jekyll skips underscore folders).
- One poster frame per clip, `0N-poster.jpg`, 1280 wide, ~30 KB, taken at t=1s.
- Measured on the largest clip (02, 13.1 MB): 4.7 MB at these settings, no visible loss.

### Loading strategy (`_layouts/home.html`)
1. Inline script at the top of `<body>` picks a random clip index and sets `#bg-canvas`'s `background-image` to that clip's poster. First paint shows imagery at ~100 ms.
2. One `<video muted playsinline autoplay preload="auto">` is created immediately with `src` set to the streaming mp4 (no XHR, no blob). With faststart the browser needs only the moov atom and first GOP (~300 KB) before `canplay`.
3. `pixi.min.js` moves out of `head.html` into `home.html` (and `info.html`) with `defer`. When both PIXI is ready and the video has `loadedmetadata`, the existing mask compositing (`startPlayback`) runs unchanged. If PIXI fails, the raw video plays full-bleed behind the canvas as a fallback.
4. On `playing`, a second hidden `<video>` prefetches the next random clip. On `ended`, textures are swapped rather than `src`, avoiding the black gap.
5. `prefers-reduced-motion: reduce`, `navigator.connection.saveData`, or a rejected `play()` (iOS Low Power) → poster only.
6. The "Loading…" indicator stays but hides on first `playing` (expected sub-second).

## 2. One project template

### Layout unification
- `_layouts/design.html` and `_layouts/experiment.html` are deleted. All 26 content files in `_projects`, `_designs`, `_experiments` get `layout: project`.
- `_layouts/project.html` becomes a thin shell that renders from a variable `p`: `p = page` normally, or the project found by `page.source` (a permalink) for test pages. Sections live in includes: `project-hero.html`, `project-info.html`, `project-media.html`, `project-foot.html`.
- Field handling in one place:
  - `medium`, `created`, `role` (string or list; list items joined with " / ") render as single-line facts. The one file that fakes a list with `<br>-` inside a string (`_designs/04_maquette.md`) is normalised to a real list.
  - `collaborators` (person/role/url) and `artists` (person/url, shown under "Lead artist") render as a two-column name/role list.
  - `credits` (experiments, free text `"Name ~ Role"`) are split on `" ~ "` in Liquid into the same name/role list.
  - `showings`, `grants`, `awards`, `press`, `links` (text/url): text split on `" ~ "` into venue + year; year shown in grey. Links underlined; nothing else is.
  - Section order everywhere: Description → Created → Medium → Role → Lead artist → Collaborators/Credits → Select showings → Grants → Awards → Press → Links.
- Content edits: remove the trailing hero-duplicate iframe from `documentation` in each file that has one. Replace `"NN.gif"` entries with `"NN.mp4"` where the GIF has been converted.

### Hero (kept, tightened)
- Same 100vh poster + uppercase title + play arrow.
- Poster is `preview-1600.jpg` via a `<link rel="preload" as="image">` in head plus the inline background; the 3–7 MB originals are never sent.
- YouTube/Vimeo iframe gets `data-src`; the click handler sets `src` with `autoplay=1`. No player bytes until someone presses play.
- Play arrow becomes a `<button aria-label="Play video">` wrapping the SVG. Nav items become `<a>` with spans, not `<h1>`.

### Credits block, variant A "rail"
- Grid `200px minmax(0, 640px)`, column gap 64, container padding 24 (32 ≥900px), `max-width: 968px`, top margin 96px under the hero.
- Below 900px: single column, label above content, 16px gap.
- Rail labels: 15px uppercase, letter-spacing .04em, no underline, `position: sticky; top: 32px` ≥900px. Same as `.index .rail h1` on the info page.
- Body 17px/1.55 (19px ≥900px). Description first, in the measure.
- Facts (Created, Medium, Role): one row each, single line.
- Name/role lists: `grid-template-columns: max-content 1fr; column-gap: 24px; row-gap: 8px`; names white (linked ones underlined, `text-underline-offset: .12em`), roles `#888`.
- Venue/year lists: same grid, year in `#888` on the left, venue on the right.
- Rows separated by 32px; 64px before the media section; a `1px solid #333` rule between text and media.
- No "Title" row: the hero h1 is the title.

### Credits block, variant B "tidy two-column"
- Container `width: min(90vw, 1200px)`, top margin 96px. Two columns ≥700px: description `58%`, facts `34%`, gap `8%`. Single column below.
- Labels 13px uppercase, letter-spacing .04em, `#888`, no underline, `margin: 32px 0 8px` (0 top on the first).
- Values 17px/1.5. Same name/role and venue/year treatment as A (grey roles and years, links the only underlines).
- No Title row.

### Test pages
- `_pages/test-castle-door-a.md`, `-b.md`, `test-bag-of-worms-a.md`, `-b.md`, `test-maquette-a.md`, `-b.md`: `layout: project`, `source: /castle_door/` etc., `info_layout: rail|columns`, permalinks under `/test/…/`. Deleted, along with the losing include, once Matt picks.
- The chosen variant becomes the only one; `info_layout` goes away.

### Media section (both variants)
- CSS grid, `grid-template-columns: repeat(2, 1fr)`, gap 8px (16px ≥900px); `:first-child { grid-column: 1 / -1 }`; single column below 600px.
- Container width equals the credits block's container in each variant so edges align.
- Images: `aspect-ratio: 3/2; object-fit: cover; width: 100%` (96 of 129 documentation images are 3:2; the 16:9 ones lose 12% of their height to the crop). `loading="lazy" decoding="async"`, `alt=""` (decorative documentation of the piece), `srcset` of 800 and 1600 derivatives with `sizes` matching the grid.
- Converted GIFs render as `<video autoplay loop muted playsinline preload="none" poster>` in the same cell; a small IntersectionObserver plays/pauses them on visibility.
- Iframes span both columns at `aspect-ratio: 16/9`, `loading="lazy"`, `title` set from the project title.
- All items shown; the "See more" toggle and `.project-media__extra` go away (lazy loading handles bytes; the grid halves the scroll).
- Footer: the HOME link stays at the existing type size with margins cut to 96px/128px; the Liquid-inside-a-comment project list is removed.

## 3. Bytes everywhere

- `bin/derivatives.sh` (kept in repo, idempotent, ffmpeg-based): for every documentation JPG and every `preview.jpg`, write `-1600.jpg` and `-800.jpg` next to it (`-q:v 4`, never upscales). Originals stay.
- GIFs over 1 MB → h264 mp4 (`-crf 26`, even dimensions, faststart) plus a `-poster.jpg`. Original GIFs move to `_originals/<collection>/<project>/` (kept, not published).
- `head.html`: remove the Google Analytics placeholder (`UA-12345-1`, `document.write`), the `String.prototype.includes` polyfill, `x-ua-compatible`. `@font-face` keeps only the valid `.woff` (with `.otf` fallback), adds `font-display: swap`, and the woff is preloaded. Broken `.woff2` and `.eot` files deleted.
- `header.html` menu: preview images become `data-bg` applied on hover/scroll, the `<img>` uses `preview-800.jpg` and is skipped when `innerWidth >= 1024`. Opening a menu drops from ~22 MB to under 200 KB.
- `.main-nav` / `.menu-wrapper` transitions animate `opacity` only; the `mousemove` handler writes only on change.
- `home.scss` dead `video {}`, `#info-expand`, `.nav-hidden`, `.nav-home`, `.nav-teaching`, `.expanded`, `.project-seemore*` removed.

## 4. Semantics and accessibility (bundled)

- Each credits section is a `<section>` with an `<h2>` label and a `<p>` or `<ul>`; no `<div>` or bare `<h2>` inside `<ul>`, no `<u>`.
- Description rendered with `markdownify` directly, no wrapping `<p>`.
- External links get `rel="noopener noreferrer"`.
- `:focus-visible` outline (1px white, offset 3px) moves from `info.scss` to `base.scss` so it applies sitewide.
- One `<h1>` per page (the hero title). Section labels are `<h2>` visually styled as small caps.

## Housekeeping

- `docs/` is added to `exclude` in `_config.yml` so this spec is not published as a page.
- `_pages/test-*.md` and the losing variant include are deleted after Matt's pick.

## Testing and review

- `bundle exec jekyll build` succeeds; every page in `_site` for the 26 collection items contains the expected number of media cells (Liquid loop check via grep).
- Chrome: home page transfer size before/after, time to first `playing` event; project page transfer for castle_door and meat_puppet_arcade before/after.
- Desktop (1440) and phone (390 via iframe harness) screenshots of: home, castle_door A and B, bag_of_worms A and B, maquette A and B (design layout), a converted-GIF page (meat_puppet_arcade).
- Manual: play arrow loads and autoplays the video; menu opens and previews; keyboard reaches play button and links.
- Matt reviews in the browser; nothing is committed until he asks.

## Expected result

| Page | Today | After |
|---|---|---|
| Home first frame | ~73 MB before playback can start | ~300 KB streamed, poster at ~100 ms |
| castle_door | ~15 MB | ~0.5 MB initial, ~1.5 MB fully scrolled |
| meat_puppet_arcade | ~68 MB | ~0.6 MB initial, ~6 MB fully scrolled |
| Published `assets/` | 349 MB | roughly 180 MB (originals kept under `_originals/`, which is not published) |
