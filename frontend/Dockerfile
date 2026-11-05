# ==========================================
# Stage 1: Build React Application
# ==========================================
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies with clean cache
COPY package.json package-lock.json ./
RUN npm ci || npm install

# Build arguments for frontend configuration
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL

# Copy source and build
COPY . .
RUN npm run build

# ==========================================
# Stage 2: Serve with Non-Root NGINX
# ==========================================
FROM nginxinc/nginx-unprivileged:alpine AS runner

# Copy custom NGINX configuration
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled assets from builder
COPY --from=builder --chown=nginx:nginx /app/dist /usr/share/nginx/html

# Explicit non-root user (UID 101 in unprivileged nginx)
USER 101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q -O - http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
