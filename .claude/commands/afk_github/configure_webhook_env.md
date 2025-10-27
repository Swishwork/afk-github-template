# Configure Webhook Environment Variables

Configure all required environment variables for AFK GitHub webhook setup.

## Task

1. Verify PORT is set (from detect_next_port step)
2. Verify GITHUB_REPO_URL is set (from setup_github_repo step)
3. Check for ANTHROPIC_API_KEY (required for ADW)
4. Set up log directory path
5. Display summary of configuration

## Implementation

```bash
# Load .env
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    exit 1
fi

source .env

# Check PORT
if [ -z "$PORT" ]; then
    echo "❌ PORT not set in .env"
    echo "Run: Read and execute .claude/commands/afk_github/detect_next_port.md"
    exit 1
fi
echo "✅ PORT: $PORT"

# Check GITHUB_REPO_URL
if [ -z "$GITHUB_REPO_URL" ]; then
    echo "❌ GITHUB_REPO_URL not set in .env"
    echo "Run: Read and execute .claude/commands/afk_github/setup_github_repo.md"
    exit 1
fi
echo "✅ GITHUB_REPO_URL: $GITHUB_REPO_URL"

# Check ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  ANTHROPIC_API_KEY not set in .env"
    echo ""
    echo "ADW requires an Anthropic API key to function."
    echo ""
    echo "Get your API key here:"
    echo "  🔗 https://console.anthropic.com/settings/keys"
    echo ""
    echo "Steps:"
    echo "  1. Go to https://console.anthropic.com/settings/keys"
    echo "  2. Click 'Create Key' (if you don't have one)"
    echo "  3. Copy the key (starts with sk-ant-)"
    echo "  4. Add to .env:"
    echo "       ANTHROPIC_API_KEY=sk-ant-your-actual-key-here"
    echo ""
    exit 1
fi
echo "✅ ANTHROPIC_API_KEY: sk-ant-***${ANTHROPIC_API_KEY: -4}"

# Set up logs directory
mkdir -p logs
echo "✅ Logs directory: logs/"

# Check for optional GITHUB_PAT
if [ -z "$GITHUB_PAT" ]; then
    echo "ℹ️  GITHUB_PAT not set (will use gh auth)"
else
    echo "✅ GITHUB_PAT: ghp_***${GITHUB_PAT: -4}"
fi

echo ""
echo "=========================================="
echo "Environment Configuration Complete"
echo "=========================================="
echo "PORT:              $PORT"
echo "GITHUB_REPO_URL:   $GITHUB_REPO_URL"
echo "LOG_PATH:          logs/afk_github_webhook_${PORT}.log"
echo "=========================================="
echo ""
```

## Expected Output

- Verification of all required environment variables
- Summary of configuration
