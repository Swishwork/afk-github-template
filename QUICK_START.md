# Quick Start: Adding AFK GitHub to Your Project

## Step 1: Copy the Setup Guide
```bash
cp /Users/kristopherfe/Projects/afk-github-template/AFK_GITHUB_SETUP.md /path/to/your-project/
```

## Step 2: Run Assessment in Claude Code
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

## Step 3: Follow the Plan
Claude Code will guide you through:
1. Copying required files from `/Users/kristopherfe/Projects/afk-github-template`
2. Setting up dependencies
3. Configuring environment variables
4. Running the automated setup

## Step 4: Test
```
Read and execute: .claude/commands/afk_github/test_afk_github.md
```

## That's It!
Your project now has AFK GitHub workflows enabled.

---

**Template Location**: `/Users/kristopherfe/Projects/afk-github-template`
**Full Guide**: `AFK_GITHUB_SETUP.md`
