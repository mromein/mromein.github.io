#!/usr/bin/env bash
# Writes X-1600.jpg and X-800.jpg beside every documentation/preview JPG.
# Idempotent: regenerates only when the source is newer than the output.
# Never upscales (scale='min(W,iw)'). Keeps the embedded colour profile.
set -euo pipefail
cd "$(dirname "$0")/.."

find assets/01_projects assets/02_design assets/03_experiments -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' \) \
  ! -name '*-1600.jpg' ! -name '*-800.jpg' ! -name '*-poster.jpg' -print0 |
while IFS= read -r -d '' src; do
  base="${src%.*}"
  for w in 1600 800; do
    out="$base-$w.jpg"
    if [ ! -f "$out" ] || [ "$src" -nt "$out" ]; then
      ffmpeg -v error -y -i "$src" -vf "scale='min($w,iw)':-2" -q:v 4 "$out"
      echo "wrote $out"
    fi
  done
done
