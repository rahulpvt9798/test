#!/bin/bash
mkdir -p /app/hls

INPUT="https://webiptv.site/foxtelpvt.php/c1566607e84d4dd0bc7e53bc26943d14/index.mpd"
KEY="a2ba14ee5ef4440d8e56a8bb5403117d:b77a334fd7aff9c9960ca7785a20ea66"

PORT=${PORT:-10000}

ffmpeg -allowed_extensions ALL -decryption_key $KEY -i "$INPUT" \
  -map 0:v:0 -c:v:0 libx264 -b:v:0 500k  -s:v:0 426x240  -maxrate:v:0 550k  -bufsize:v:0 1000k  -r:v:0 50 \
  -map 0:v:0 -c:v:1 libx264 -b:v:1 800k  -s:v:1 640x360  -maxrate:v:1 850k  -bufsize:v:1 1500k  -r:v:1 50 \
  -map 0:v:0 -c:v:2 libx264 -b:v:2 1200k -s:v:2 854x480  -maxrate:v:2 1300k -bufsize:v:2 2000k -r:v:2 50 \
  -map 0:v:0 -c:v:3 libx264 -b:v:3 2500k -s:v:3 1280x720 -maxrate:v:3 2800k -bufsize:v:3 4000k -r:v:3 50 \
  -map 0:v:0 -c:v:4 libx264 -b:v:4 5000k -s:v:4 1920x1080 -maxrate:v:4 5500k -bufsize:v:4 6000k -r:v:4 50 \
  -map 0:a:0 -c:a aac -ar 48000 -b:a 128k -ac 2 \
  -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list \
  -var_stream_map "v:0,a:0,name:240p v:1,a:0,name:360p v:2,a:0,name:480p v:3,a:0,name:720p v:4,a:0,name:1080p" \
  -master_pl_name master.m3u8 -hls_segment_filename "/app/hls/%v_%03d.ts" /app/hls/%v.m3u8

echo "server { listen $PORT; root /app/hls; autoindex on; }" > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
