#!/usr/bin/env bash
# ==============================================================================
# Automated Local Deployment Script
# Purpose: Pull/build images, restart services, and perform health verification
# ==============================================================================

set -euo pipefail

# Text formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Resolve script directory and workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

log_info "Starting deployment in: ${PROJECT_ROOT}"

# 1. Check prerequisites
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH."
    exit 1
fi

COMPOSE_CMD=""
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    log_error "Neither 'docker compose' nor 'docker-compose' was found."
    exit 1
fi

log_info "Using Docker Compose command: ${COMPOSE_CMD}"

# 2. Check for environment file
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        log_warn ".env file not found. Creating from .env.example..."
        cp .env.example .env
    else
        log_error ".env or .env.example missing."
        exit 1
    fi
fi

# 3. Build & start containers
log_info "Building and orchestrating multi-container services..."
${COMPOSE_CMD} build --pull
${COMPOSE_CMD} up -d --remove-orphans

# 4. Health Check Verification
log_info "Awaiting service health checks..."

MAX_RETRIES=15
RETRY_COUNT=0
HEALTHY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    BACKEND_STATUS=$(${COMPOSE_CMD} ps backend --format "{{.Health}}" 2>/dev/null || echo "starting")
    FRONTEND_STATUS=$(${COMPOSE_CMD} ps frontend --format "{{.Health}}" 2>/dev/null || echo "starting")

    if [[ "$BACKEND_STATUS" == *"healthy"* ]] && [[ "$FRONTEND_STATUS" == *"healthy"* ]]; then
        HEALTHY=true
        break
    fi

    log_info "Waiting for containers to be healthy... (Backend: ${BACKEND_STATUS}, Frontend: ${FRONTEND_STATUS}) [Attempt $((RETRY_COUNT + 1))/${MAX_RETRIES}]"
    sleep 3
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ "$HEALTHY" = true ]; then
    log_success "All services are up and healthy!"
    echo "------------------------------------------------------"
    echo -e "Frontend URL:  ${GREEN}http://localhost${NC} (or http://localhost:80)"
    echo -e "Backend API:   ${GREEN}http://localhost:8000/api/hello/${NC}"
    echo -e "Health Check:  ${GREEN}http://localhost:8000/api/health/${NC}"
    echo "------------------------------------------------------"
    ${COMPOSE_CMD} ps
    exit 0
else
    log_error "Deployment healthcheck timed out. Displaying logs for debugging:"
    ${COMPOSE_CMD} logs --tail=50
    exit 1
fi

