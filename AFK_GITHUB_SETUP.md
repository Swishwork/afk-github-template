# AFK GitHub Workflow Setup Guide

**Version**: 1.0
**Purpose**: Bootstrap AFK (Away From Keyboard) GitHub workflows in any project
**Usage**: Copy this file to a new project and follow the automated setup instructions below

---

## 🚀 Quick Start (New Project Setup)

If you're setting up AFK GitHub in a **new project**, start here:

### Step 1: Copy This File
Copy this `AFK_GITHUB_SETUP.md` to your new project's root directory.

### Step 2: Run Automated Assessment
Use Claude Code to assess what's needed:

**Prompt to Claude Code:**
```
Analyze this project to determine what's needed to enable AFK GitHub workflows.

Read AFK_GITHUB_SETUP.md and follow the "Automated Setup Assessment" section.

Search the codebase for:
1. Existing .claude/commands/ structure
2. Existing adws/ directory and ADW system
3. Existing scripts/ directory
4. Environment configuration (.env, .env.sample)

Report:
- What's already present
- What needs to be copied from afk-github-template project
- What I can set up automatically
- What requires manual user input
- Step-by-step setup plan
```

---

## 📋 Automated Setup Assessment

**For Claude Code Agent**: When asked to set up AFK GitHub, follow these steps:

### Assessment Checklist

Run these checks and report findings:

#### 1. Check Project Structure
```bash
# Check for .claude directory
test -d .claude && echo "✅ .claude/ exists" || echo "❌ .claude/ missing"

# Check for .claude/commands
test -d .claude/commands && echo "✅ .claude/commands/ exists" || echo "❌ .claude/commands/ missing"

# Check for AFK GitHub commands
test -d .claude/commands/afk_github && echo "✅ afk_github commands exist" || echo "❌ afk_github commands missing"

# Check for ADW system
test -d adws && echo "✅ adws/ exists" || echo "❌ adws/ missing"

# Check for adws/adw_modules
test -d adws/adw_modules && echo "✅ adw_modules/ exists" || echo "❌ adw_modules/ missing"

# Check for webhook server
test -f adws/adw_triggers/trigger_webhook.py && echo "✅ webhook server exists" || echo "❌ webhook server missing"

# Check for scripts directory
test -d scripts && echo "✅ scripts/ exists" || echo "❌ scripts/ missing"

# Check for Tailscale scripts
test -f scripts/start_tailscale_funnel.sh && echo "✅ Tailscale scripts exist" || echo "❌ Tailscale scripts missing"
```

#### 2. Check Dependencies
```bash
# Check GitHub CLI
gh --version && echo "✅ GitHub CLI installed" || echo "❌ GitHub CLI missing"

# Check Tailscale
tailscale version && echo "✅ Tailscale installed" || echo "❌ Tailscale missing"

# Check Claude Code
claude --version && echo "✅ Claude Code installed" || echo "❌ Claude Code missing"

# Check Python/uv
uv --version && echo "✅ uv installed" || echo "❌ uv missing"
```

#### 3. Check Environment Configuration
```bash
# Check for .env file
test -f .env && echo "✅ .env exists" || echo "⚠️  .env missing (will create)"

# Check for .env.sample
test -f .env.sample && echo "✅ .env.sample exists" || echo "⚠️  .env.sample missing"
```

#### 4. Check Git Repository
```bash
# Check for GitHub remote
git remote get-url origin && echo "✅ GitHub repo configured" || echo "❌ No GitHub remote"
```

### Assessment Report Template

After running checks, provide this report to the user:

```
🔍 AFK GitHub Setup Assessment
════════════════════════════════════════════════

📊 Current State:
✅ Present:
  - [List what exists]

❌ Missing:
  - [List what's missing]

🤖 I Can Setup Automatically:
  1. [List auto-setup items]

👤 You Need To Provide:
  1. [List manual items]

📋 Recommended Setup Plan:
  Step 1: [First step]
  Step 2: [Second step]
  ...

Would you like me to proceed with the automated setup?
```

---

## 📦 What Needs to Be Copied

### Source Project
All files should be copied from: `afk-github-template` (or whichever project has working AFK GitHub)

### Required Files/Directories

#### 1. AFK GitHub Commands (Always Required)
```
Source: afk-github-template/.claude/commands/afk_github/
Destination: .claude/commands/afk_github/

Files:
├── detect_next_port.md
├── setup_github_repo.md
├── configure_webhook_env.md
├── start_tailscale_funnel.md
├── setup_github_webhook.md
├── start_webhook_server.md
├── setup_afk_github.md (master command)
└── test_afk_github.md (test command)
```

#### 2. ADW System (Required if not present)
```
Source: afk-github-template/adws/
Destination: adws/

Critical files:
├── adw_modules/
│   ├── agent.py (IMPORTANT: Contains working directory fix!)
│   ├── workflow_ops.py
│   ├── github.py
│   ├── git_ops.py
│   ├── state.py
│   ├── data_types.py
│   └── utils.py
├── adw_triggers/
│   └── trigger_webhook.py (webhook server)
├── adw_plan.py
├── adw_build.py
└── adw_test.py
```

#### 3. Helper Scripts (Required)
```
Source: afk-github-template/scripts/
Destination: scripts/

Files:
├── start_tailscale_funnel.sh
└── stop_tailscale_funnel.sh
```

#### 4. Spec File (Optional but Recommended)
```
Source: afk-github-template/specs/afk-github-workflow-setup.md
Destination: specs/afk-github-workflow-setup.md
```

---

## 🛠️ Automated Setup Steps

**For Claude Code Agent**: Execute these steps in order:

### Phase 1: Copy Required Files

```bash
# Define source project path
SOURCE_PROJECT="/Users/kristopherfe/Projects/afk-github-template"

# Copy AFK GitHub commands
mkdir -p .claude/commands
cp -r "$SOURCE_PROJECT/.claude/commands/afk_github" .claude/commands/

# Copy ADW system (if not present)
if [ ! -d "adws" ]; then
  cp -r "$SOURCE_PROJECT/adws" .
  echo "✅ Copied ADW system"
else
  echo "⚠️  adws/ already exists - merging key files"
  # Copy critical files that contain fixes
  cp "$SOURCE_PROJECT/adws/adw_modules/agent.py" adws/adw_modules/
  cp "$SOURCE_PROJECT/adws/adw_modules/workflow_ops.py" adws/adw_modules/
  cp "$SOURCE_PROJECT/adws/adw_triggers/trigger_webhook.py" adws/adw_triggers/
fi

# Copy helper scripts
mkdir -p scripts
cp "$SOURCE_PROJECT/scripts/start_tailscale_funnel.sh" scripts/
cp "$SOURCE_PROJECT/scripts/stop_tailscale_funnel.sh" scripts/
chmod +x scripts/*.sh

# Copy spec (optional)
mkdir -p specs
cp "$SOURCE_PROJECT/specs/afk-github-workflow-setup.md" specs/ 2>/dev/null || true

echo "✅ Files copied successfully"
```

### Phase 2: Verify Dependencies

```bash
echo "Checking dependencies..."

# Check each dependency and report
gh --version || echo "❌ Install GitHub CLI: brew install gh"
tailscale version || echo "❌ Install Tailscale: brew install tailscale"
claude --version || echo "❌ Install Claude Code CLI"
uv --version || echo "❌ Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"

echo "✅ Dependency check complete"
```

### Phase 3: Run Setup Command

Once files are copied and dependencies verified:

```
Read and execute: .claude/commands/afk_github/setup_afk_github.md
```

This will:
1. Detect next available port
2. Check/create GitHub repository
3. Configure environment variables
4. Start Tailscale funnel
5. Create GitHub webhook
6. Start webhook server

---

## 🎯 What Each Component Does

### AFK GitHub Commands
- **Modular setup commands** - Each handles one aspect (port, repo, webhook, etc.)
- **Master orchestration** - `setup_afk_github.md` chains everything together
- **Test command** - `test_afk_github.md` verifies the setup works

### ADW System
- **Core automation engine** - Plans and implements solutions from GitHub issues
- **Webhook server** - Listens for GitHub events (issue creation, comments)
- **Agent modules** - Execute Claude Code commands programmatically

### Helper Scripts
- **Tailscale management** - Start/stop Tailscale funnels for exposing webhooks

---

## 🔧 Manual Configuration Items

These require user input and cannot be fully automated:

### 1. Environment Variables
Add to `.env`:
```bash
# AFK GitHub Configuration
PORT=8002                                    # Next available port
GITHUB_REPO_URL=https://github.com/owner/repo

# ADW Configuration (Required)
ANTHROPIC_API_KEY=sk-ant-...

# Optional Configuration
CLAUDE_CODE_PATH=claude                      # If not in PATH
GITHUB_PAT=ghp_...                          # Optional, uses 'gh auth' if not set
```

### 2. GitHub Authentication
```bash
gh auth login
```

### 3. Tailscale Setup
- Install Tailscale app
- Sign in and connect to your network
- Verify running: `tailscale status`

---

## 🧪 Testing the Setup

After setup is complete, run the test command:

```
Read and execute: .claude/commands/afk_github/test_afk_github.md
```

This will:
1. ✅ Check webhook server is running
2. ✅ Check Tailscale funnel is active
3. ✅ Create a test issue
4. ✅ Verify webhook delivery
5. ✅ Show you the logs

---

## 📱 Using AFK GitHub

Once set up, you can:

1. **Create issues from mobile** - Use GitHub mobile app
2. **Trigger workflows** - Add `adw_plan_build` in issue body
3. **Monitor progress** - Watch issue comments for updates
4. **Review PRs** - ADW creates pull requests automatically

### Workflow Triggers

Add these to issue body or comments to trigger ADW:

- `adw_plan_build` - Plan and implement solution
- `adw_plan_build_test` - Plan, implement, and test
- `adw_build <adw_id>` - Continue building from existing plan

---

## 🔄 Multi-Project Setup

### Port Management

Each project needs its own port:
- **afk-github-template**: Port 8001
- **Project 2**: Port 8002
- **Project 3**: Port 8003
- etc.

The `detect_next_port` command automatically finds the next available port.

### Simultaneous Projects

You can run AFK GitHub for multiple projects at once:
- Each has its own webhook server (different port)
- Each has its own Tailscale funnel
- Each has its own GitHub webhook
- All use the same Tailscale machine URL (different ports)

---

## 🐛 Troubleshooting

### Common Issues

**Webhook not receiving events:**
- Check Tailscale funnel is running: `tailscale funnel status`
- Verify webhook URL in GitHub: `https://github.com/owner/repo/settings/hooks`
- Check logs: `tail -f logs/afk_github_webhook_<port>.log`

**Port already in use:**
- Run: `.claude/commands/afk_github/detect_next_port.md`
- Use the next available port

**ADW not processing issues:**
- Check webhook server logs
- Verify `adw_plan_build` is in issue body
- Check environment variables are set

---

## 📚 Architecture Overview

```
Mobile Device (GitHub App)
    ↓ Create issue with "adw_plan_build"
GitHub Webhook
    ↓ HTTPS POST
Tailscale Funnel (Port 8002)
    ↓ Forward to localhost:8002
Webhook Server (adws/adw_triggers/trigger_webhook.py)
    ↓ Parse event, detect workflow
ADW System (adws/)
    ↓ Execute plan + build
Pull Request Created
    ↓ Notification to mobile
Review & Merge from Mobile
```

---

## 🔐 Security Notes

- **Tailscale Funnel**: End-to-end encrypted via WireGuard
- **GitHub Webhooks**: HTTPS with SSL verification
- **No port forwarding**: No router configuration needed
- **Authentication**: Uses GitHub CLI auth, no tokens in code
- **Audit logs**: All access logged in Tailscale admin console

---

## 📖 Additional Resources

- **Tailscale Funnel Docs**: https://tailscale.com/kb/1223/funnel
- **GitHub Webhooks**: https://docs.github.com/en/webhooks
- **Claude Code**: https://docs.anthropic.com/en/docs/claude-code
- **ADW System**: See `adws/README.md` in this project

---

## 🎓 Learning Path

For developers new to this system:

1. **Start here**: Read this guide top to bottom
2. **Run assessment**: Let Claude Code analyze your project
3. **Copy files**: Use the automated copy commands
4. **Run setup**: Execute `setup_afk_github.md`
5. **Test it**: Create a test issue with `adw_plan_build`
6. **Monitor**: Watch the logs and GitHub comments
7. **Iterate**: Try different workflows and issues

---

## 🔄 Version History

- **v1.0** (2025-01-26): Initial release with automated assessment
  - Bootstrap setup guide
  - Automated project analysis
  - Copy commands for all required files
  - Self-documenting architecture

---

**Questions?** Create an issue in the afk-github-template repo or consult the technical spec at `specs/afk-github-workflow-setup.md`

**Ready to begin?** Copy this file to your new project and run the automated assessment!
