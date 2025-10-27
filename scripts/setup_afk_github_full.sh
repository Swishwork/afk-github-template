#!/bin/bash

# AFK GitHub Full Setup Script
# This script runs all setup steps in sequence with verification

set -e  # Exit on any error

echo "🚀 AFK GitHub Full Setup"
echo "========================"
echo ""

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo ""
    echo "${BLUE}========================================${NC}"
    echo "${BLUE}$1${NC}"
    echo "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo "${GREEN}✅ $1${NC}"
}

print_error() {
    echo "${RED}❌ $1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo "${BLUE}ℹ️  $1${NC}"
}

# =============================================================================
# Step 0: Prerequisites Check
# =============================================================================
print_step "Step 0/6: Checking Prerequisites"

PREREQS_OK=true

# Check for required tools
command -v gh >/dev/null 2>&1 && print_success "GitHub CLI installed" || { print_error "GitHub CLI (gh) not installed. Run: brew install gh"; PREREQS_OK=false; }
command -v tailscale >/dev/null 2>&1 && print_success "Tailscale installed" || { print_error "Tailscale not installed. Run: brew install tailscale"; PREREQS_OK=false; }
command -v claude >/dev/null 2>&1 && print_success "Claude Code CLI installed" || { print_error "Claude Code CLI not installed"; PREREQS_OK=false; }
command -v uv >/dev/null 2>&1 && print_success "uv installed" || { print_error "uv not installed. Run: curl -LsSf https://astral.sh/uv/install.sh | sh"; PREREQS_OK=false; }
command -v jq >/dev/null 2>&1 && print_success "jq installed" || { print_error "jq not installed. Run: brew install jq"; PREREQS_OK=false; }

# Check Tailscale is running
if tailscale status >/dev/null 2>&1; then
    print_success "Tailscale is running"
else
    print_error "Tailscale is not running. Please start the Tailscale app."
    PREREQS_OK=false
fi

# Check gh auth
if gh auth status >/dev/null 2>&1; then
    print_success "GitHub CLI authenticated"
else
    print_error "GitHub CLI not authenticated. Run: gh auth login"
    PREREQS_OK=false
fi

if [ "$PREREQS_OK" = false ]; then
    echo ""
    print_error "Prerequisites not met. Please install missing tools and try again."
    exit 1
fi

echo ""
print_success "All prerequisites met!"

# =============================================================================
# Step 1: Detect Available Port
# =============================================================================
print_step "Step 1/6: Detecting Available Port"

# Check if .env exists
if [ ! -f .env ]; then
    touch .env
    print_info "Created .env file"
fi

# Function to check if port is in use
check_port() {
    lsof -i:$1 >/dev/null 2>&1
    return $?
}

# Check if PORT is already in .env - use grep/cut instead of source
CURRENT_PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)

if [ -n "$CURRENT_PORT" ]; then
    print_info "PORT is set to $CURRENT_PORT in .env"
    if check_port $CURRENT_PORT; then
        print_warning "Port $CURRENT_PORT is already in use, finding next available..."
        CURRENT_PORT=""
    else
        print_success "Port $CURRENT_PORT is available"
        PORT=$CURRENT_PORT
    fi
fi

# Find next available port if needed
if [ -z "$CURRENT_PORT" ]; then
    PORT=8001
    while check_port $PORT; do
        print_info "Port $PORT is in use, trying next..."
        PORT=$((PORT + 1))
        if [ $PORT -gt 8100 ]; then
            print_error "No available ports found in range 8001-8100"
            exit 1
        fi
    done

    # Update .env
    if grep -q "^PORT=" .env 2>/dev/null; then
        # Update existing PORT line (handle both macOS and Linux sed)
        if [ "$(uname)" = "Darwin" ]; then
            sed -i '' "s/^PORT=.*/PORT=$PORT/" .env
        else
            sed -i "s/^PORT=.*/PORT=$PORT/" .env
        fi
    else
        # Add PORT line
        echo "PORT=$PORT" >> .env
    fi

    print_success "Port $PORT is available and set in .env"
fi

# =============================================================================
# Step 2: Setup GitHub Repository
# =============================================================================
print_step "Step 2/6: Verifying GitHub Repository"

# Check if this is a git repo
if [ ! -d .git ]; then
    print_error "This is not a git repository"
    echo ""
    echo "Initialize git first: git init"
    exit 1
fi

# Check for GitHub remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    print_error "No GitHub remote configured"
    echo ""
    echo "To create a new GitHub repository:"
    echo "  1. Run: gh repo create --source=. --public (or --private)"
    echo "  2. Follow the prompts"
    echo ""
    echo "To connect to an existing repository:"
    echo "  1. Run: git remote add origin https://github.com/username/repo.git"
    echo ""
    exit 1
fi

# Verify it's a GitHub URL
if ! echo "$REMOTE_URL" | grep -q "github.com"; then
    print_warning "Remote is not a GitHub repository: $REMOTE_URL"
    exit 1
fi

print_success "GitHub repository configured: $REMOTE_URL"

# Update .env with GITHUB_REPO_URL
if grep -q "^GITHUB_REPO_URL=" .env 2>/dev/null; then
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=$REMOTE_URL|" .env
    else
        sed -i "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=$REMOTE_URL|" .env
    fi
else
    echo "GITHUB_REPO_URL=$REMOTE_URL" >> .env
fi

print_success "Updated GITHUB_REPO_URL in .env"

# =============================================================================
# Step 3: Configure Environment Variables
# =============================================================================
print_step "Step 3/6: Configuring Environment"

# Load environment variables using grep/cut
PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)
GITHUB_REPO_URL=$(grep "^GITHUB_REPO_URL=" .env 2>/dev/null | cut -d'=' -f2-)
ANTHROPIC_API_KEY=$(grep "^ANTHROPIC_API_KEY=" .env 2>/dev/null | cut -d'=' -f2)

# Check PORT
if [ -z "$PORT" ]; then
    print_error "PORT not set in .env"
    exit 1
fi
print_success "PORT: $PORT"

# Check GITHUB_REPO_URL
if [ -z "$GITHUB_REPO_URL" ]; then
    print_error "GITHUB_REPO_URL not set in .env"
    exit 1
fi
print_success "GITHUB_REPO_URL: $GITHUB_REPO_URL"

# Check ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ] || [ "$ANTHROPIC_API_KEY" = "sk-ant-your-key-here" ]; then
    print_error "ANTHROPIC_API_KEY not set in .env"
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
    echo "Then run this script again."
    exit 1
fi
print_success "ANTHROPIC_API_KEY: sk-ant-***${ANTHROPIC_API_KEY: -4}"

# Set up logs directory
mkdir -p logs
print_success "Logs directory: logs/"

# =============================================================================
# Step 4: Start Tailscale Funnel
# =============================================================================
print_step "Step 4/6: Starting Tailscale Funnel"

# Check Tailscale version
TAILSCALE_VERSION=$(tailscale version | head -n1 | cut -d' ' -f1)
print_info "Tailscale version: $TAILSCALE_VERSION"

# Check if funnel is already running on this port
FUNNEL_STATUS=$(tailscale funnel status 2>/dev/null || echo "")
if echo "$FUNNEL_STATUS" | grep -q ":$PORT"; then
    print_success "Tailscale funnel already running on port $PORT"
else
    print_info "Starting funnel to localhost:$PORT..."

    # Try new CLI syntax first (v1.88+)
    if tailscale funnel --bg $PORT 2>/dev/null; then
        print_success "Funnel started with --bg flag (new CLI)"
    else
        # Fallback to old syntax for older versions
        print_warning "New CLI syntax failed, trying old syntax..."
        tailscale funnel $PORT &
        FUNNEL_PID=$!
        print_info "Funnel started in background (PID: $FUNNEL_PID)"
    fi

    # Give it a moment to start
    sleep 5
fi

# Verify funnel is running
print_info "Verifying funnel status..."
if tailscale funnel status 2>/dev/null | grep -q ":$PORT"; then
    print_success "Funnel verified running on port $PORT"
else
    print_error "Funnel failed to start"
    exit 1
fi

# Get the funnel URL
MACHINE_NAME=$(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$MACHINE_NAME" ]; then
    print_error "Could not get Tailscale machine name"
    exit 1
fi

WEBHOOK_URL="https://${MACHINE_NAME}/gh-webhook"
print_success "Public webhook URL: $WEBHOOK_URL"

# =============================================================================
# Step 5: Setup GitHub Webhook
# =============================================================================
print_step "Step 5/6: Setting up GitHub Webhook"

# Extract owner/repo from GITHUB_REPO_URL using sed/cut (portable)
OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    print_error "Could not parse GitHub repository URL: $GITHUB_REPO_URL"
    exit 1
fi

print_info "Repository: $OWNER/$REPO"
print_info "Webhook URL: $WEBHOOK_URL"

# Check if webhook already exists
EXISTING_WEBHOOK=$(gh api repos/$OWNER/$REPO/hooks 2>/dev/null | jq -r ".[] | select(.config.url == \"$WEBHOOK_URL\") | .id")

if [ -n "$EXISTING_WEBHOOK" ]; then
    print_success "Webhook already exists (ID: $EXISTING_WEBHOOK)"
else
    print_info "Creating new webhook..."

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
        --jq '.id' 2>/dev/null)

    if [ -n "$WEBHOOK_ID" ]; then
        print_success "Webhook created successfully (ID: $WEBHOOK_ID)"
    else
        print_error "Failed to create webhook"
        exit 1
    fi
fi

# =============================================================================
# Step 6: Start Webhook Server
# =============================================================================
print_step "Step 6/6: Starting Webhook Server"

# Check if webhook server script exists
if [ ! -f adws/adw_triggers/trigger_webhook.py ]; then
    print_error "Webhook server not found at adws/adw_triggers/trigger_webhook.py"
    exit 1
fi

LOG_FILE="logs/afk_github_webhook_${PORT}.log"

# Check if server is already running
if lsof -i:$PORT 2>/dev/null | grep -iq python; then
    print_warning "Server already running on port $PORT"
    PID=$(lsof -ti:$PORT)
    print_info "PID: $PID"
    print_info "Log file: $LOG_FILE"
else
    print_info "Starting webhook server on port $PORT..."
    print_info "Log file: $LOG_FILE"

    # Start the webhook server in background
    cd adws
    nohup uv run python adw_triggers/trigger_webhook.py --port $PORT > "../$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    cd ..

    # Give it a moment to start
    sleep 3

    # Check if it's running
    if lsof -i:$PORT 2>/dev/null | grep -iq python; then
        print_success "Webhook server started successfully"
        print_info "PID: $SERVER_PID"
    else
        print_error "Failed to start webhook server"
        echo ""
        echo "Check logs: cat $LOG_FILE"
        exit 1
    fi
fi

# =============================================================================
# Final Summary
# =============================================================================
echo ""
echo "${GREEN}========================================${NC}"
echo "${GREEN}✅ AFK GitHub Setup Complete!${NC}"
echo "${GREEN}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Port:              $PORT"
echo "  Repository:        $OWNER/$REPO"
echo "  Webhook URL:       $WEBHOOK_URL"
echo "  Log file:          $LOG_FILE"
echo ""
echo "📱 To trigger a workflow from mobile:"
echo "  1. Open GitHub mobile app"
echo "  2. Navigate to: $OWNER/$REPO"
echo "  3. Create new issue"
echo "  4. Add 'adw_plan_build' in the body"
echo "  5. Submit issue"
echo ""
echo "📊 Monitor activity:"
echo "  tail -f $LOG_FILE"
echo ""
echo "🧪 Test the setup:"
echo "  Read and execute: .claude/commands/afk_github/test_afk_github.md"
echo ""
echo "🔗 Webhook URL:"
echo "  $WEBHOOK_URL"
echo ""
echo "${GREEN}========================================${NC}"
echo ""
