#!/bin/sh
set -e

PORT=${PORT:-10000}
LIVE_DIR="/app/live"

mkdir -p $LIVE_DIR

# Base TS URL
TS_URL="http://agh2019.xyz:80/live/SOFIANBENAISSA/X7KJL94/83174.ts"

# Number of segments to keep
SEGMENTS=5

# Start nginx first (foreground in a separate terminal)
echo "server { listen $PORT; root $LIVE_DIR; autoindex on; }" > /etc/nginx/conf.d/default.conf
nginx &

counter=0

# Main loop runs in foreground
while true; do
    segment=$(printf "seg_%03d.ts" $counter)
    curl -s "$TS_URL" -o "$LIVE_DIR/$segment"

    # Remove old segments
    oldest=$((counter-SEGMENTS))
    [ $oldest -ge 0 ] && rm -f "$LIVE_DIR/seg_$(printf "%03d" $oldest).ts"

    # Generate .m3u8 playlist
    {
      echo "#EXTM3U"
      echo "#EXT-X-VERSION:3"
      echo "#EXT-X-TARGETDURATION:6"
      echo "#EXT-X-MEDIA-SEQUENCE:$((counter>=SEGMENTS?counter-SEGMENTS+1:0))"
      for i in $(seq $((counter-SEGMENTS+1)) $counter); do
          [ $i -lt 0 ] && continue
          echo "#EXTINF:6.0,"
          echo "seg_$(printf "%03d" $i).ts"
      done
    } > "$LIVE_DIR/live.m3u8"

    counter=$((counter+1))
    sleep 5
done
