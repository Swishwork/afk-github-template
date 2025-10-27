# Setup GitHub Webhook

Create or update the GitHub webhook to point to your Tailscale funnel URL.

## Task

1. Get the Tailscale machine name and construct webhook URL
2. Get GitHub repo owner/name from GITHUB_REPO_URL
3. Use `gh` CLI to create or update webhook
4. Configure webhook for issue and issue_comment events

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

if [ -z "$PORT" ] || [ -z "$GITHUB_REPO_URL" ]; then
    echo "❌ PORT or GITHUB_REPO_URL not set in .env"
    echo ""
    echo "Run these first:"
    echo "  1. Read and execute .claude/commands/afk_github/detect_next_port.md"
    echo "  2. Read and execute .claude/commands/afk_github/setup_github_repo.md"
    exit 1
fi

# Get Tailscale machine name
if ! command -v tailscale >/dev/null 2>&1; then
    echo "❌ Tailscale not installed"
    echo ""
    echo "Install Tailscale:"
    echo "  brew install tailscale"
    exit 1
fi

MACHINE_NAME=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$MACHINE_NAME" ]; then
    echo "❌ Could not get Tailscale machine name"
    echo "Is Tailscale running?"
    exit 1
fi

# Construct webhook URL
WEBHOOK_URL="https://${MACHINE_NAME}/gh-webhook"

echo "Webhook URL: $WEBHOOK_URL"
echo ""

# Extract owner/repo from GITHUB_REPO_URL using sed/cut (portable)
OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "❌ Could not parse GitHub repository URL: $GITHUB_REPO_URL"
    exit 1
fi

echo "Repository: $OWNER/$REPO"
echo ""

# Check if webhook already exists
EXISTING_WEBHOOK=$(gh api repos/$OWNER/$REPO/hooks 2>/dev/null | jq -r ".[] | select(.config.url == \"$WEBHOOK_URL\") | .id")

if [ -n "$EXISTING_WEBHOOK" ]; then
    echo "✅ Webhook already exists (ID: $EXISTING_WEBHOOK)"
    echo "URL: $WEBHOOK_URL"
else
    echo "Creating new webhook..."

    # Create webhook
    WEBHOOK_ID=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        repos/$OWNER/$REPO/hooks \
        -f name='web' \
        -f "config[url]=$WEBHOOK_URL" \
        -f config[content_type]=json \
        -f config[insecure_ssl]=0 \
        -f events[]=issues \
        -f events[]=issue_comment \
        -f active=true \
        --jq '.id')

    if [ -n "$WEBHOOK_ID" ]; then
        echo "✅ Webhook created successfully (ID: $WEBHOOK_ID)"
        echo "URL: $WEBHOOK_URL"
    else
        echo "❌ Failed to create webhook"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "GitHub Webhook Configuration"
echo "=========================================="
echo "Webhook URL: $WEBHOOK_URL"
echo "Events: issues, issue_comment"
echo "Repository: $OWNER/$REPO"
echo ""
echo "To test, create an issue with 'adw_plan_build' in the body"
echo "=========================================="
echo ""
EOFSCRIPT
```

## Expected Output

- Confirmation that webhook is created or already exists
- Webhook URL and configuration details
