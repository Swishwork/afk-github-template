# AFK GitHub Workflow Template

**Version**: 1.0
**Purpose**: Clean template for setting up AFK (Away From Keyboard) GitHub workflows in any project
**Source**: Canonical source for all AFK GitHub components

---

## 🎯 What is AFK GitHub?

AFK GitHub enables you to trigger and monitor AI Developer Workflows (ADW) from your mobile device using the GitHub app. Create issues, add comments, and watch as ADW automatically plans, implements, and creates pull requests - all while you're away from your keyboard.

---

## 📦 What's Included

This template contains **only** the files needed for AFK GitHub workflows:

```
afk-github-template/
├── README.md                          # This file
├── AFK_GITHUB_SETUP.md               # Setup guide for new projects
├── .claude/commands/afk_github/      # AFK GitHub slash commands (TO BE ADDED)
├── adws/                             # AI Developer Workflow system
│   ├── adw_modules/                  # Core modules
│   ├── adw_triggers/                 # Webhook server
│   └── *.py                          # Workflow scripts
├── scripts/                          # Helper scripts (TO BE ADDED)
│   ├── start_tailscale_funnel.sh
│   └── stop_tailscale_funnel.sh
└── specs/                            # Technical specifications (TO BE ADDED)
    └── afk-github-workflow-setup.md
```

---

## 🚀 Quick Start (Setting Up a New Project)

### Step 1: Copy AFK_GITHUB_SETUP.md
```bash
cp /path/to/afk-github-template/AFK_GITHUB_SETUP.md /path/to/your-project/
```

### Step 2: Run Assessment in Claude Code
In your target project, prompt Claude Code:
```
Read AFK_GITHUB_SETUP.md and analyze this project to determine what's needed for AFK GitHub workflows.

Report:
- What's already present
- What needs to be copied from afk-github-template
- What you can set up automatically
- What requires manual user input
```

### Step 3: Copy Required Files
Based on the assessment, copy the necessary components from this template to your project.

### Step 4: Run Setup
Execute the master setup command:
```
Read and execute: .claude/commands/afk_github/setup_afk_github.md
```

---

## 📋 Components to Copy

### Required for All Projects

1. **ADW System** (`adws/`)
   - Core automation engine
   - Webhook server
   - Planning and implementation scripts

2. **AFK GitHub Commands** (`.claude/commands/afk_github/`)
   - Port detection
   - GitHub repo setup
   - Environment configuration
   - Tailscale funnel management
   - Webhook creation
   - Server management
   - Testing

3. **Helper Scripts** (`scripts/`)
   - Tailscale funnel start/stop scripts

### Optional

4. **Technical Spec** (`specs/afk-github-workflow-setup.md`)
   - Detailed technical documentation
   - Implementation details

---

## 🔧 Prerequisites

Before using this template, ensure you have:

- **GitHub CLI** (`gh`) - `brew install gh`
- **Tailscale** - https://tailscale.com/download
- **Claude Code CLI** - https://docs.anthropic.com/en/docs/claude-code
- **Python with uv** - `curl -LsSf https://astral.sh/uv/install.sh | sh`

---

## 🎓 How It Works

```
Mobile Device (GitHub App)
    ↓ Create issue with "adw_plan_build"
GitHub Webhook
    ↓ HTTPS POST
Tailscale Funnel
    ↓ Forward to localhost:PORT
Webhook Server (adws/adw_triggers/trigger_webhook.py)
    ↓ Parse event, detect workflow
ADW System
    ↓ Plan → Build → Test
Pull Request Created
    ↓ Review on mobile
```

---

## 🌟 Key Features

- **Mobile-First**: Create and manage issues from GitHub mobile app
- **Automated Workflows**: ADW handles planning, implementation, and PR creation
- **Multi-Project**: Run simultaneously for multiple projects (different ports)
- **Persistent URLs**: Tailscale provides stable webhook URLs
- **Secure**: End-to-end encrypted, no port forwarding needed

---

## 📖 Documentation

- **Setup Guide**: `AFK_GITHUB_SETUP.md` - Start here for new projects
- **Technical Spec**: `specs/afk-github-workflow-setup.md` - Deep dive
- **ADW System**: `adws/README.md` - Core automation engine

---

## 🔄 Updating This Template

When improvements are made to AFK GitHub workflows:

1. Update files in this template project
2. Commit changes with clear descriptions
3. Other projects can pull latest improvements

---

## 🤝 Contributing

This template is the canonical source for AFK GitHub workflows. All improvements should be:

1. Tested in a real project first
2. Copied back to this template
3. Documented in the changelog below

---

## 📝 Changelog

### v1.0 (2025-01-26)
- Initial template creation
- Core ADW system from tac-5
- Working directory fix in agent.py
- Automated setup guide

---

## ❓ FAQ

**Q: Do I need this template as a GitHub repo?**
A: Not required, but recommended for easy distribution and version control.

**Q: Can I modify the files for my project?**
A: Yes! Copy to your project and customize as needed.

**Q: How do I update when the template improves?**
A: Copy updated files from the template to your project.

**Q: What if I have Cloudflare references in my project?**
A: This template has NO Cloudflare dependencies. It's Tailscale-only.

---

## 🔗 Related Projects

- **tac-5**: Original implementation and testing ground
- **TaxMachine3**: Reference implementation with Tailscale

---

**Ready to enable AFK GitHub in your project?**
Start with `AFK_GITHUB_SETUP.md`!
