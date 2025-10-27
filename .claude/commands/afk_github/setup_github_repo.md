# Setup GitHub Repository for AFK GitHub

Verify or create the GitHub repository and configure the remote.

## Task

1. Check if this is a git repository
2. Check if GitHub remote is configured
3. If not, guide user through creating/connecting GitHub repo
4. Update GITHUB_REPO_URL in `.env`

## Implementation

```bash
# Check if this is a git repo
if [ ! -d .git ]; then
    echo "❌ This is not a git repository"
    echo "Run: git init"
    exit 1
fi

# Check for GitHub remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo "⚠️  No GitHub remote configured"
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
if [[ ! "$REMOTE_URL" =~ github\.com ]]; then
    echo "⚠️  Remote is not a GitHub repository: $REMOTE_URL"
    exit 1
fi

echo "✅ GitHub repository configured: $REMOTE_URL"

# Update .env with GITHUB_REPO_URL
if grep -q "^GITHUB_REPO_URL=" .env 2>/dev/null; then
    sed -i '' "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=$REMOTE_URL|" .env
else
    echo "GITHUB_REPO_URL=$REMOTE_URL" >> .env
fi

echo "✅ Updated GITHUB_REPO_URL in .env"
echo ""
```

## Expected Output

- Confirmation that GitHub remote is configured
- `.env` updated with GITHUB_REPO_URL
