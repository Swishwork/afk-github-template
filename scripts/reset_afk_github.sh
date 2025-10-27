#!/bin/bash

# AFK GitHub Reset Script
# Stops all running services and cleans up for a fresh start

echo "🔄 Resetting AFK GitHub setup..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo "${GREEN}✅ $1${NC}"
}

print_info() {
    echo "ℹ️  $1"
}

# Stop webhook server
if [ -f .env ]; then
    PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)
    if [ -n "$PORT" ]; then
        print_info "Stopping webhook server on port $PORT..."
        lsof -ti:$PORT 2>/dev/null | xargs kill 2>/dev/null || true
        sleep 1

        # Verify it stopped
        if lsof -i:$PORT >/dev/null 2>&1; then
            echo "${YELLOW}⚠️  Server still running on port $PORT, trying force kill...${NC}"
            lsof -ti:$PORT | xargs kill -9 2>/dev/null || true
        fi
        print_success "Webhook server stopped"
    fi
fi

# Stop Tailscale funnel
print_info "Stopping Tailscale funnel..."
tailscale funnel --https=443 off 2>/dev/null || true
print_success "Tailscale funnel stopped"

# Clear logs (optional - ask user)
if [ -d logs ] && [ "$(ls -A logs/afk_github_webhook_*.log 2>/dev/null)" ]; then
    echo ""
    echo "Clear webhook logs? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Clearing logs..."
        rm -f logs/afk_github_webhook_*.log
        print_success "Logs cleared"
    else
        print_info "Logs preserved"
    fi
fi

echo ""
print_success "Reset complete!"
echo ""
echo "To run setup again:"
echo "  bash scripts/setup_afk_github_full.sh"
echo ""
