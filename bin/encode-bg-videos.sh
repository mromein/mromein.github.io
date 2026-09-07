#!/usr/bin/env bash
# Re-encodes the home splash clips: 1920x1080 h264, no audio, faststart, ~6.5 Mbps cap,
# plus a poster frame. Originals move to _originals/assets/bg_videos/.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p _originals/assets/bg_videos

for n in 01 02 03 04 05 06 07 08 09; do
  src="assets/bg_videos/$n.mp4"
  [ -f "$src" ] || src="_originals/assets/bg_videos/$n.mp4"
  ffmpeg -v error -y -i "$src" -an \
    -vf "scale=1920:1080:flags=lanczos" \
    -c:v libx264 -preset slow -crf 19 -maxrate 6500k -bufsize 13000k -profile:v high -level 4.1 \
    -pix_fmt yuv420p -g 60 -keyint_min 60 -sc_threshold 0 -movflags +faststart \
    "assets/bg_videos/$n-1080.mp4"
  ffmpeg -v error -y -ss 1 -i "$src" -frames:v 1 -vf scale=1280:720 -q:v 6 "assets/bg_videos/$n-poster.jpg"
  [ -f "assets/bg_videos/$n.mp4" ] && mv "assets/bg_videos/$n.mp4" "_originals/assets/bg_videos/$n.mp4"
  printf "%s: %s bytes\n" "$n-1080.mp4" "$(stat -f%z "assets/bg_videos/$n-1080.mp4")"
done
