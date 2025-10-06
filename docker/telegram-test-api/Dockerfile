# Dockerfile for telegram-test-api
# Builds a containerized mock Telegram Bot API server for testing

FROM node:18-alpine

WORKDIR /app

# Clone and setup telegram-test-api
RUN apk add --no-cache git && \
    git clone https://github.com/jehy/telegram-test-api.git . && \
    npm install && \
    npm run build && \
    apk del git

# Copy sample config
RUN cp config/config.sample.json config/config.json

# Expose port (default is 9000, but we'll override in docker-compose)
EXPOSE 9000

# Start the server
CMD ["npm", "start"]
