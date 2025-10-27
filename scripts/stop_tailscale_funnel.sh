#!/bin/bash

# Stop Tailscale Funnel

# Get PORT from .env or use default
if [ -f .env ]; then
    source .env
fi

PORT=${PORT:-8001}

echo "Stopping Tailscale funnel on port $PORT..."

# The funnel is managed by the tailscaled daemon
# We need to stop the funnel configuration, not kill processes

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    echo "Tailscale is not installed."
    exit 1
fi

# Stop the funnel on the configured port
tailscale funnel off $PORT 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Tailscale funnel stopped successfully on port $PORT."
else
    echo "No active funnel found on port $PORT or already stopped."
fi

echo "Funnel shutdown complete."