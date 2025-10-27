# Setup AFK GitHub (Master Command)

Complete automated setup of AFK GitHub workflows. This command orchestrates all setup steps.

## Overview

This command will:
1. Detect next available port
2. Verify/setup GitHub repository
3. Configure environment variables
4. Start Tailscale funnel
5. Create GitHub webhook
6. Start webhook server

## Prerequisites

Before running this command, ensure you have:
- GitHub CLI (`gh`) installed and authenticated
- Tailscale installed and running
- Claude Code CLI installed
- Python with `uv` installed
- Anthropic API key

## Implementation

Run each setup command in sequence:

### Step 1: Detect Next Available Port

Read and execute: `.claude/commands/afk_github/detect_next_port.md`

This will find an available port starting from 8001 and save it to `.env`.

### Step 2: Setup GitHub Repository

Read and execute: `.claude/commands/afk_github/setup_github_repo.md`

This will verify your GitHub repository is configured and update `.env` with the repo URL.

### Step 3: Configure Environment

Read and execute: `.claude/commands/afk_github/configure_webhook_env.md`

This will verify all required environment variables are set, including ANTHROPIC_API_KEY.

**⚠️  IMPORTANT**: If ANTHROPIC_API_KEY is not set, you must add it to `.env`:
```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Get your API key from: https://console.anthropic.com/

### Step 4: Start Tailscale Funnel

Read and execute: `.claude/commands/afk_github/start_tailscale_funnel.md`

This will start the Tailscale funnel to expose your webhook server publicly.

**Note**: Make sure the Tailscale app is running (check menu bar).

### Step 5: Setup GitHub Webhook

Read and execute: `.claude/commands/afk_github/setup_github_webhook.md`

This will create a GitHub webhook pointing to your Tailscale funnel URL.

### Step 6: Start Webhook Server

Read and execute: `.claude/commands/afk_github/start_webhook_server.md`

This will start the ADW webhook server to listen for GitHub events.

## Final Steps

Once all commands complete successfully:

1. **Test the setup**:
   ```
   Read and execute: .claude/commands/afk_github/test_afk_github.md
   ```

2. **Create a test issue** from your mobile:
   - Open GitHub mobile app
   - Navigate to your repository
   - Create new issue
   - Title: "Test AFK GitHub"
   - Body: "adw_plan_build: Create a simple hello world function"
   - Submit

3. **Monitor the logs**:
   ```bash
   tail -f logs/afk_github_webhook_<port>.log
   ```

## Troubleshooting

If any step fails:

- **Port detection fails**: Check if ports 8001-8100 are in use
- **GitHub repo not found**: Run `gh repo create` or `git remote add origin ...`
- **ANTHROPIC_API_KEY missing**: Add it to `.env`
- **Tailscale not running**: Start Tailscale app from menu bar
- **Webhook creation fails**: Check `gh auth status`
- **Server won't start**: Check logs in `logs/afk_github_webhook_<port>.log`

## Success Criteria

Setup is complete when:
- ✅ Port is detected and set in `.env`
- ✅ GitHub repository is configured
- ✅ All environment variables are set
- ✅ Tailscale funnel is running
- ✅ GitHub webhook is created
- ✅ Webhook server is running and healthy

You can now trigger workflows from your mobile device by creating GitHub issues!
