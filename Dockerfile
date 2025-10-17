# Use Alpine FFmpeg image
FROM jrottenberg/ffmpeg:6.0-alpine

# Install nginx and bash
RUN apk add --no-cache nginx bash

# Set working directory
WORKDIR /app

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Run start.sh as container entrypoint
CMD ["/app/start.sh"]
