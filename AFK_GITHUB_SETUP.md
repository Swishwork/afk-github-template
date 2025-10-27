# AFK GitHub Quick Start & Setup Guide

**Version**: 1.0
**Purpose**: Bootstrap AFK (Away From Keyboard) GitHub workflows in any project
**Usage**: Copy this single file to a new project and get started

---

## ⚠️ Prerequisites

Before starting setup, ensure you have:

### Required Tools
- **GitHub CLI** (`gh`) - Install: `brew install gh`
- **Tailscale** (v1.88+) - Install: `brew install tailscale` or download from https://tailscale.com/download
- **Claude Code CLI** - Install from https://docs.anthropic.com/en/docs/claude-code
- **Python/uv** - Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **jq** - Install: `brew install jq`

### Shell Compatibility

**IMPORTANT: These scripts use bash syntax and may not work correctly in zsh (macOS default).**

If you're on macOS or using zsh, you have two options:

**Option 1: Switch to bash** (Recommended for manual commands)
```bash
bash
# Then run the setup commands
```

**Option 2: Run scripts directly** (Recommended for automated setup)
```bash
# Scripts are already marked #!/bin/bash so they'll run correctly:
bash scripts/setup_afk_github_full.sh
```

**Note**: Multi-line commands copied directly to zsh may produce parse errors. If you see `(eval):1: parse error near ')'`, you're hitting the shell compatibility issue.

### Tailscale Version Check

Check your Tailscale version - the CLI syntax changed in v1.88:
```bash
tailscale version
```

If you're on an older version, you may need to update: `brew upgrade tailscale`

---

## 🚀 Quick Start (For Developers)

Setting up AFK GitHub in a **new project**? Choose your method:

### Method 1: Fully Automated (Recommended)

**The fastest way to get started:**

1. **Copy required files** from `afk-github-template` to your project
2. **Run the all-in-one setup script:**
   ```bash
   bash scripts/setup_afk_github_full.sh
   ```

That's it! The script handles everything:
- ✅ Checks prerequisites
- ✅ Detects available port
- ✅ Configures GitHub repository
- ✅ Starts Tailscale funnel
- ✅ Creates GitHub webhook
- ✅ Starts webhook server

**Note**: You'll need to add your `ANTHROPIC_API_KEY` to `.env` before running the script.

### Method 2: Claude Code Guided Setup

For more control or troubleshooting:

**Step 1: Copy This File**
```bash
cp /path/to/afk-github-template/AFK_GITHUB_SETUP.md /path/to/your-project/
```

**Step 2: Run Assessment in Claude Code**
In your project, prompt Claude Code:
```
Read AFK_GITHUB_SETUP.md and analyze this project.

Search the codebase for existing ADW components and report:
- What's already present
- What needs to be copied from afk-github-template
- What you can setup automatically
- What requires my input

Then provide a step-by-step setup plan.
```

**Step 3: Follow the Plan**
Claude Code will guide you through:
1. Copying required files from `/Users/kristopherfe/Projects/afk-github-template`
2. Setting up dependencies
3. Configuring environment variables
4. Running the automated setup

**Step 4: Test**
```
Read and execute: .claude/commands/afk_github/test_afk_github.md
```

**Your project now has AFK GitHub workflows enabled!**

---

## 📖 Background: What is AFK GitHub?

AFK (Away From Keyboard) GitHub enables you to trigger AI-powered development workflows from your mobile device using the GitHub app. No desktop required.

### How It Works

When you create a GitHub issue from your phone with `adw_plan_build` in the body:

1. **GitHub webhook fires** → Sends event to your Tailscale funnel URL
2. **Tailscale funnel** → Securely forwards to your local webhook server
3. **Webhook server** → Parses the event and triggers ADW system
4. **ADW system** → Reads the issue, plans a solution using Claude Code
5. **ADW implements** → Writes code, runs tests, creates commits
6. **Pull request created** → ADW opens PR with implementation
7. **Review on mobile** → You review and merge from GitHub mobile app

### Key Components

**ADW (AI Developer Workflow)**
- Core automation engine that plans and implements solutions
- Uses Claude Code CLI to execute development tasks
- Reads GitHub issues → Plans → Implements → Creates PRs

**Tailscale Funnel**
- Secure encrypted tunnel that exposes your local webhook server to the internet
- No port forwarding, no router configuration needed
- Provides stable HTTPS URL for GitHub webhooks
- End-to-end WireGuard encryption

**Webhook Server** (`adws/adw_triggers/trigger_webhook.py`)
- Listens for GitHub events (issue creation, issue comments)
- Detects workflow triggers in issue body/comments
- Spawns ADW processes to handle requests
- Logs all activity for debugging

**Claude Code Commands** (`.claude/commands/afk_github/`)
- Modular setup commands for each component
- Port detection, repo setup, webhook configuration
- Orchestrated by master `setup_afk_github.md` command

### Workflow Triggers

Add these keywords to issue body or comments:
- `adw_plan_build` - Plan and implement solution
- `adw_plan_build_test` - Plan, implement, and run tests
- `adw_build <adw_id>` - Continue from existing plan

### Why This Approach?

**Mobile-First Development**
- Create issues, trigger workflows, review PRs - all from your phone
- Perfect for capturing ideas on-the-go
- No need to be at your desk to start development work

**Secure & Private**
- Tailscale provides enterprise-grade security
- No public endpoints, no exposed ports
- Runs entirely on your local machine

**Multi-Project Support**
- Run webhook servers for multiple projects simultaneously
- Each project gets its own port and funnel
- All managed through one Tailscale connection

---

## 📋 For Claude Code: Automated Setup Assessment

**When asked to set up AFK GitHub, follow these steps:**

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
  1. ANTHROPIC_API_KEY - Get it here: https://console.anthropic.com/settings/keys
  2. [Any other manual items]

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

#### 4. Environment Template (Required)
```
Source: afk-github-template/.env.sample
Destination: .env.sample (reference) and .env (your config)

Copy .env.sample to .env and fill in:
- ANTHROPIC_API_KEY (required)
- Other values are auto-configured during setup
```

#### 5. Spec File (Optional but Recommended)
```
Source: afk-github-template/specs/afk-github-workflow-setup.md
Destination: specs/afk-github-workflow-setup.md
```

---

## 🛠️ Automated Setup Steps

**For Claude Code Agent**: Execute these steps in order:

### Phase 1: Copy Required Files & Setup Environment

```bash
# Define source project path
SOURCE_PROJECT="/Users/kristopherfe/Projects/afk-github-template"

# Copy environment template
cp "$SOURCE_PROJECT/.env.sample" .
cp "$SOURCE_PROJECT/.env.sample" .env
echo "✅ Copied .env.sample and created .env"
echo "⚠️  IMPORTANT: Edit .env and add your ANTHROPIC_API_KEY"

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

**Verify this phase succeeded before continuing:**
```bash
# Check that required files exist
test -f .env && echo "✅ .env exists" || echo "❌ .env missing"
test -d .claude/commands/afk_github && echo "✅ AFK commands copied" || echo "❌ Commands missing"
test -d adws && echo "✅ ADW system present" || echo "❌ ADW missing"
test -f scripts/start_tailscale_funnel.sh && echo "✅ Scripts copied" || echo "❌ Scripts missing"
```

---

### Phase 2: Verify Dependencies

```bash
echo "Checking dependencies..."

# Check each dependency and report
DEPS_OK=true

gh --version >/dev/null 2>&1 && echo "✅ GitHub CLI installed" || { echo "❌ Install GitHub CLI: brew install gh"; DEPS_OK=false; }
tailscale version >/dev/null 2>&1 && echo "✅ Tailscale installed" || { echo "❌ Install Tailscale: brew install tailscale"; DEPS_OK=false; }
claude --version >/dev/null 2>&1 && echo "✅ Claude Code installed" || { echo "❌ Install Claude Code CLI"; DEPS_OK=false; }
uv --version >/dev/null 2>&1 && echo "✅ uv installed" || { echo "❌ Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"; DEPS_OK=false; }
jq --version >/dev/null 2>&1 && echo "✅ jq installed" || { echo "❌ Install jq: brew install jq"; DEPS_OK=false; }

if [ "$DEPS_OK" = true ]; then
    echo ""
    echo "✅ All dependencies installed"
else
    echo ""
    echo "❌ Some dependencies are missing. Please install them before continuing."
    exit 1
fi
```

**Verify this phase succeeded before continuing:**
```bash
# Quick dependency verification
command -v gh >/dev/null && command -v tailscale >/dev/null && command -v claude >/dev/null && command -v uv >/dev/null && command -v jq >/dev/null && echo "✅ All deps ready" || echo "❌ Missing deps"
```

---

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

**Verify each step with these commands:**

After port detection:
```bash
grep "^PORT=" .env && echo "✅ Port configured" || echo "❌ Port not set"
```

After Tailscale funnel start:
```bash
tailscale funnel status | grep -q "Funnel on" && echo "✅ Funnel running" || echo "❌ Funnel not active"
```

After webhook server start:
```bash
PORT=$(grep "^PORT=" .env | cut -d'=' -f2)
lsof -i:$PORT | grep -iq python && echo "✅ Server running" || echo "❌ Server not running"
```

After webhook creation:
```bash
GITHUB_REPO_URL=$(grep "^GITHUB_REPO_URL=" .env | cut -d'=' -f2-)
OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')
gh api repos/$OWNER/$REPO/hooks 2>/dev/null | jq -r '.[].config.url' | grep -q "gh-webhook" && echo "✅ Webhook configured" || echo "❌ Webhook missing"
```

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

### 1. ANTHROPIC_API_KEY (Required)

**This is the ONLY value you must provide manually.**

After copying `.env.sample` to `.env`, add your Anthropic API key:

**Get your API key here: https://console.anthropic.com/settings/keys**

```bash
# Add to .env:
ANTHROPIC_API_KEY=sk-ant-your-actual-key-here
```

**Steps:**
1. Go to https://console.anthropic.com/settings/keys
2. Click "Create Key" (if you don't have one)
3. Copy the key (starts with `sk-ant-`)
4. Paste it into `.env` as shown above

**All other values in `.env` are auto-configured:**
- `PORT` - Auto-detected by `detect_next_port` command
- `GITHUB_REPO_URL` - Auto-configured by `setup_github_repo` command
- `GITHUB_PAT` - Optional, defaults to `gh auth` if not set
- `CLAUDE_CODE_PATH` - Optional, defaults to `claude` in PATH

Example of a complete `.env` after setup:
```bash
# REQUIRED: You must provide this
ANTHROPIC_API_KEY=sk-ant-api03-abc123...

# AUTO-CONFIGURED: Set automatically during setup
PORT=8002
GITHUB_REPO_URL=https://github.com/owner/repo

# OPTIONAL: Usually not needed
CLAUDE_CODE_PATH=claude
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

### Reset Everything and Start Fresh

If setup gets into a bad state, use the reset script to completely reset:

```bash
bash scripts/reset_afk_github.sh
```

This will:
- ✅ Stop the webhook server
- ✅ Stop the Tailscale funnel
- ✅ Optionally clear logs

Then you can run setup again:
```bash
bash scripts/setup_afk_github_full.sh
```

### Common Issues & Solutions

**Issue: Parse errors in zsh** (`(eval):1: parse error near ')'`)
- **Solution**: Run `bash` first, or save commands to a `.sh` file and run with `bash script.sh`

**Issue: Tailscale funnel commands fail** (`"the CLI for serve and funnel has changed"`)
- **Solution**: Update Tailscale: `brew upgrade tailscale` (need v1.88+)

**Issue: Webhook not receiving events**
- **Check**: `tailscale funnel status` - Is funnel running on your port?
- **Check**: GitHub webhook settings: `https://github.com/owner/repo/settings/hooks`
- **Check**: Logs: `tail -f logs/afk_github_webhook_<port>.log`
- **Fix**:
  ```bash
  # Restart funnel with correct port
  source .env
  tailscale funnel --bg $PORT
  ```

**Issue: Port already in use**
- **Check**: `lsof -i:8001` (or your port)
- **Fix**: Run port detection: `Read and execute .claude/commands/afk_github/detect_next_port.md`

**Issue: Process matching fails** ("Python" not found but webhook is running)
- **Root cause**: Case-sensitive grep looking for "Python" but process is "python3.1"
- **Fix**: Already fixed in updated scripts (now uses `grep -iq python`)

**Issue: ADW not processing issues**
- **Check**: Webhook server logs for errors
- **Check**: Verify `adw_plan_build` is in issue body (not just title)
- **Check**: Environment variables are set: `cat .env | grep ANTHROPIC_API_KEY`
- **Fix**:
  ```bash
  # Verify server is running
  source .env
  lsof -i:$PORT | grep -iq python && echo "✅ Running" || echo "❌ Not running"

  # If not running, restart it
  cd adws && nohup uv run python adw_triggers/trigger_webhook.py > ../logs/afk_github_webhook_${PORT}.log 2>&1 &
  ```

**Issue: Environment variables not loading**
- **Root cause**: `source .env` doesn't work reliably across shells
- **Fix**: Use explicit extraction:
  ```bash
  PORT=$(grep "^PORT=" .env | cut -d'=' -f2)
  GITHUB_REPO_URL=$(grep "^GITHUB_REPO_URL=" .env | cut -d'=' -f2-)
  ```

**Issue: Funnel doesn't persist between terminal sessions**
- **Root cause**: Backgrounding with `&` may not persist
- **Fix**: Use `--bg` flag: `tailscale funnel --bg $PORT`
- **Verify**: `tailscale funnel status` and wait 5 seconds, check again

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

## 📌 Template Location

**Source Template**: `/Users/kristopherfe/Projects/afk-github-template`

---

**Questions?** Create an issue in the afk-github-template repo or consult the technical spec at `specs/afk-github-workflow-setup.md`

**Ready to begin?** Jump to the Quick Start section at the top of this file!
