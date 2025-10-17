FROM jrottenberg/ffmpeg:6.0-alpine
RUN apk add --no-cache nginx bash

WORKDIR /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
