FROM alpine:3.18

RUN apk add --no-cache bash curl nginx

WORKDIR /app

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
