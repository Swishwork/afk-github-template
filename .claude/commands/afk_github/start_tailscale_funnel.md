# Start Tailscale Funnel

Start the Tailscale funnel to expose the webhook server to the internet.

## Task

1. Verify Tailscale is installed and running
2. Get the PORT from `.env`
3. Start Tailscale funnel on that port
4. Display the public webhook URL

## Implementation

```bash
#!/bin/bash
# Wrapped in bash heredoc for zsh compatibility

bash << 'EOFSCRIPT'
set -e

# Load PORT from .env - use grep/cut instead of source
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    echo ""
    echo "Run this first:"
    echo "  Read and execute .claude/commands/afk_github/detect_next_port.md"
    exit 1
fi

PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)

if [ -z "$PORT" ]; then
    echo "❌ PORT not set in .env"
    echo ""
    echo "Run this first:"
    echo "  Read and execute .claude/commands/afk_github/detect_next_port.md"
    exit 1
fi

echo "Starting Tailscale funnel on port $PORT..."
echo ""

# Check if Tailscale is installed and running
if ! command -v tailscale >/dev/null 2>&1; then
    echo "❌ Tailscale is not installed"
    echo ""
    echo "Install Tailscale:"
    echo "  brew install tailscale"
    echo "  Or download from: https://tailscale.com/download"
    exit 1
fi

# Check if Tailscale is connected
if ! tailscale status >/dev/null 2>&1; then
    echo "❌ Tailscale is not running or not connected"
    echo ""
    echo "Please start the Tailscale app and connect to your network"
    exit 1
fi

# Check Tailscale version (warn if old)
TAILSCALE_VERSION=$(tailscale version | head -n1 | cut -d' ' -f1)
echo "Tailscale version: $TAILSCALE_VERSION"

# Check if funnel is already running on this port
FUNNEL_STATUS=$(tailscale funnel status 2>/dev/null || echo "")
if echo "$FUNNEL_STATUS" | grep -q ":$PORT"; then
    echo "✅ Tailscale funnel already running on port $PORT"
else
    # Start the funnel with --bg flag (new CLI syntax, v1.88+)
    echo "Starting funnel to localhost:$PORT..."

    # Try new CLI syntax first (v1.88+)
    if tailscale funnel --bg $PORT 2>/dev/null; then
        echo "✅ Funnel started with --bg flag (new CLI)"
    else
        # Fallback to old syntax for older versions
        echo "⚠️  New CLI syntax failed, trying old syntax..."
        tailscale funnel $PORT &
        FUNNEL_PID=$!
        echo "Funnel started in background (PID: $FUNNEL_PID)"
    fi

    # Give it a moment to start
    sleep 5
fi

# Verify funnel is running
echo ""
echo "Verifying funnel status..."
tailscale funnel status

# Get the funnel URL
MACHINE_NAME=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$MACHINE_NAME" ]; then
    echo "❌ Could not get Tailscale machine name"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Tailscale Funnel Started"
echo "=========================================="
echo "Local webhook:  http://localhost:$PORT/gh-webhook"
echo "Public webhook: https://${MACHINE_NAME}/gh-webhook"
echo ""
echo "This URL is persistent as long as:"
echo "- Tailscale is running (GUI app in menu bar)"
echo "- Funnel is enabled (stays running in background)"
echo ""
echo "To stop the funnel:"
echo "  tailscale funnel --https=443 off"
echo ""
echo "To check funnel status:"
echo "  tailscale funnel status"
echo "=========================================="
echo ""
EOFSCRIPT
```

## Expected Output

- Confirmation that Tailscale funnel is running
- Public webhook URL for GitHub configuration
