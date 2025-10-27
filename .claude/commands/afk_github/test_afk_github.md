# Test AFK GitHub Setup

Verify that the AFK GitHub workflow setup is working correctly.

## Task

1. Check if webhook server is running
2. Check if Tailscale funnel is active
3. Test local health endpoint
4. Test public health endpoint
5. Optionally create a test issue to verify end-to-end workflow

## Implementation

```bash
#!/bin/bash
# Wrapped in bash heredoc for zsh compatibility

bash << 'EOFSCRIPT'
set -e

# Load environment variables - use grep/cut instead of source
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    exit 1
fi

PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)
GITHUB_REPO_URL=$(grep "^GITHUB_REPO_URL=" .env 2>/dev/null | cut -d'=' -f2-)

if [ -z "$PORT" ]; then
    echo "❌ PORT not set in .env"
    exit 1
fi

echo "Testing AFK GitHub Setup..."
echo ""

# Test 1: Check if webhook server is running
echo "1. Checking webhook server on port $PORT..."
# Use case-insensitive grep to match both "Python" and "python3.1"
if lsof -i:$PORT | grep -iq python; then
    PID=$(lsof -ti:$PORT)
    echo "   ✅ Webhook server is running (PID: $PID)"
else
    echo "   ❌ Webhook server is NOT running"
    echo "   Run: Read and execute .claude/commands/afk_github/start_webhook_server.md"
    exit 1
fi

# Test 2: Check if Tailscale funnel is active
echo "2. Checking Tailscale funnel..."
if command -v tailscale &> /dev/null; then
    FUNNEL_STATUS=$(tailscale funnel status 2>/dev/null)
    if echo "$FUNNEL_STATUS" | grep -q "$PORT"; then
        echo "   ✅ Tailscale funnel is active on port $PORT"
        MACHINE_NAME=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//')
        echo "   Public URL: https://${MACHINE_NAME}"
    else
        echo "   ❌ Tailscale funnel is NOT active"
        echo "   Run: Read and execute .claude/commands/afk_github/start_tailscale_funnel.md"
        exit 1
    fi
else
    echo "   ⚠️  Tailscale not installed"
    exit 1
fi

# Test 3: Test local health endpoint
echo "3. Testing local health endpoint..."
LOCAL_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health)
if [ "$LOCAL_HEALTH" = "200" ]; then
    echo "   ✅ Local health check passed (HTTP $LOCAL_HEALTH)"
else
    echo "   ❌ Local health check failed (HTTP $LOCAL_HEALTH)"
    echo "   Check logs: tail -f logs/afk_github_webhook_${PORT}.log"
    exit 1
fi

# Test 4: Test public health endpoint
echo "4. Testing public health endpoint..."
PUBLIC_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" https://${MACHINE_NAME}/health)
if [ "$PUBLIC_HEALTH" = "200" ]; then
    echo "   ✅ Public health check passed (HTTP $PUBLIC_HEALTH)"
else
    echo "   ⚠️  Public health check failed (HTTP $PUBLIC_HEALTH)"
    echo "   This may be a Tailscale network issue"
fi

# Test 5: Check GitHub webhook configuration
echo "5. Checking GitHub webhook..."
# Use sed/cut instead of bash regex for portability
if [ -n "$GITHUB_REPO_URL" ]; then
    # Extract owner and repo using sed/cut (more portable than bash regex)
    OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
    REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')

    if [ -n "$OWNER" ] && [ -n "$REPO" ]; then
        WEBHOOK_URL="https://${MACHINE_NAME}/gh-webhook"
        WEBHOOK_EXISTS=$(gh api repos/$OWNER/$REPO/hooks 2>/dev/null | jq -r ".[] | select(.config.url == \"$WEBHOOK_URL\") | .id")

        if [ -n "$WEBHOOK_EXISTS" ]; then
            echo "   ✅ GitHub webhook is configured (ID: $WEBHOOK_EXISTS)"
        else
            echo "   ❌ GitHub webhook NOT found"
            echo "   Run: Read and execute .claude/commands/afk_github/setup_github_webhook.md"
            exit 1
        fi
    else
        echo "   ⚠️  Could not parse GITHUB_REPO_URL: $GITHUB_REPO_URL"
    fi
else
    echo "   ⚠️  GITHUB_REPO_URL not set in .env"
fi

echo ""
echo "=========================================="
echo "✅ AFK GitHub Setup Test Complete"
echo "=========================================="
echo ""
echo "All systems operational!"
echo ""
echo "📱 To trigger a workflow from mobile:"
echo "   1. Open GitHub mobile app"
echo "   2. Navigate to: $OWNER/$REPO"
echo "   3. Create new issue"
echo "   4. Add 'adw_plan_build' in the body"
echo "   5. Submit issue"
echo ""
echo "📊 Monitor activity:"
echo "   tail -f logs/afk_github_webhook_${PORT}.log"
echo ""
echo "🔗 Webhook URL:"
echo "   https://${MACHINE_NAME}/gh-webhook"
echo ""
echo "=========================================="
echo ""
EOFSCRIPT
```

## Expected Output

- Verification that all components are running
- Confirmation of webhook configuration
- Instructions for triggering a test workflow

## Optional: Create Test Issue

If you want to create a test issue programmatically:

```bash
#!/bin/bash
# Wrapped in bash heredoc for zsh compatibility

bash << 'EOFSCRIPT'
set -e

# Load environment - use grep/cut instead of source
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    exit 1
fi

GITHUB_REPO_URL=$(grep "^GITHUB_REPO_URL=" .env 2>/dev/null | cut -d'=' -f2-)

if [ -z "$GITHUB_REPO_URL" ]; then
    echo "❌ GITHUB_REPO_URL not set in .env"
    exit 1
fi

# Extract owner/repo using sed/cut (portable across shells)
OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "❌ Could not parse GITHUB_REPO_URL: $GITHUB_REPO_URL"
    exit 1
fi

echo "Creating test issue in $OWNER/$REPO..."
echo ""

# Create test issue
gh issue create \
    --repo "$OWNER/$REPO" \
    --title "Test AFK GitHub Workflow" \
    --body "adw_plan_build: Create a simple hello_world.py file that prints 'Hello from AFK GitHub!'"

echo ""
echo "✅ Test issue created! Check your webhook logs:"
echo "   tail -f logs/afk_github_webhook_*.log"
echo ""
EOFSCRIPT
```
