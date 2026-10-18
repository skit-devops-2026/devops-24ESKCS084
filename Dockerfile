# Stage 1: Build Frontend application
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first for efficient layer caching
COPY Frontend/package*.json ./
RUN npm ci

# Copy source code and build production bundle
COPY Frontend/ ./
RUN npm run build

# Stage 2: Production Nginx web server
FROM nginx:alpine AS runner

ARG COMMIT_SHA=main-build
ENV COMMIT_SHA=${COMMIT_SHA}

# Copy built static assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Generate dynamic health response containing commit SHA
RUN echo "{\"status\":\"healthy\",\"commit\":\"${COMMIT_SHA}\",\"service\":\"craftcv\"}" > /usr/share/nginx/html/health.json

# Expose standard HTTP port
EXPOSE 80

# Configure healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
