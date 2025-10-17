#!/bin/bash
set -e

PORT=${PORT:-10000}
LIVE_DIR="/app/live"

mkdir -p $LIVE_DIR

# Number of segments to keep
SEGMENTS=5

# Base TS URL
TS_URL="http://agh2019.xyz:80/live/SOFIANBENAISSA/X7KJL94/83174.ts"

# Start a loop to fetch TS segments
counter=0
while true; do
    segment=$(printf "seg_%03d.ts" $counter)
    curl -s "$TS_URL" -o "$LIVE_DIR/$segment"

    # Remove old segments
    oldest=$((counter-SEGMENTS))
    if [ $oldest -ge 0 ]; then
        rm -f "$LIVE_DIR/seg_$(printf "%03d" $oldest).ts"
    fi

    # Generate .m3u8 playlist
    echo "#EXTM3U" > "$LIVE_DIR/live.m3u8"
    echo "#EXT-X-VERSION:3" >> "$LIVE_DIR/live.m3u8"
    echo "#EXT-X-TARGETDURATION:6" >> "$LIVE_DIR/live.m3u8"
    echo "#EXT-X-MEDIA-SEQUENCE:$((counter>=SEGMENTS?counter-SEGMENTS+1:0))" >> "$LIVE_DIR/live.m3u8"

    for i in $(seq $((counter-SEGMENTS+1)) $counter); do
        [ $i -lt 0 ] && continue
        echo "#EXTINF:6.0," >> "$LIVE_DIR/live.m3u8"
        echo "seg_$(printf "%03d" $i).ts" >> "$LIVE_DIR/live.m3u8"
    done

    counter=$((counter+1))
    sleep 5
done &

# Serve HLS via nginx
echo "server { listen $PORT; root $LIVE_DIR; autoindex on; }" > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
