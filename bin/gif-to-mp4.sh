#!/usr/bin/env bash
# Converts every documentation GIF under assets/ to a silent h264 mp4 loop plus a poster JPEG,
# then moves the GIF to _originals/ (same relative path). Safe to re-run: skips GIFs already moved.
set -euo pipefail
cd "$(dirname "$0")/.."

find assets/01_projects assets/02_design assets/03_experiments -type f -iname '*.gif' -print0 |
while IFS= read -r -d '' gif; do
  base="${gif%.*}"
  ffmpeg -nostdin -v error -y -i "$gif" -an \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p" \
    -c:v libx264 -preset slow -crf 26 -movflags +faststart "$base.mp4"
  ffmpeg -nostdin -v error -y -i "$gif" -frames:v 1 -q:v 5 "$base-poster.jpg"
  dest="_originals/$gif"
  mkdir -p "$(dirname "$dest")"
  mv "$gif" "$dest"
  printf "%s -> %s (%s bytes)\n" "$gif" "$base.mp4" "$(stat -f%z "$base.mp4")"
done
