#!/bin/bash
set -e

# Create HLS folder
mkdir -p /app/hls

# DASH input + ClearKey
INPUT="https://webiptv.site/foxtelpvt.php/c1566607e84d4dd0bc7e53bc26943d14/index.mpd"
KEY="a2ba14ee5ef4440d8e56a8bb5403117d:b77a334fd7aff9c9960ca7785a20ea66"

# Render free plan port
PORT=${PORT:-10000}

# FFmpeg: single 1080p HLS
ffmpeg -allowed_extensions ALL \
  -decryption_key "$KEY" \
  -i "$INPUT" \
  -c:v libx264 -b:v 5000k -s 1920x1080 -r 50 \
  -c:a aac -b:a 128k -ar 48000 -ac 2 \
  -f hls \
  -hls_time 6 \
  -hls_list_size 10 \
  -hls_flags delete_segments+append_list \
  -hls_segment_filename "/app/hls/1080p_%03d.ts" \
  /app/hls/1080p.m3u8

# Serve via nginx
echo "server { listen $PORT; root /app/hls; autoindex on; }" > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
