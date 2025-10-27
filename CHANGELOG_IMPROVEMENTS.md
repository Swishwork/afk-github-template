# AFK GitHub Template Improvements

**Date**: 2025-01-27
**Version**: 2.1 (Auto-detection + UX improvements)

## Summary

This document summarizes all improvements made to the AFK GitHub template based on feedback from actual usage in multiple projects. These changes address shell compatibility issues, outdated CLI syntax, general setup pain points, and mobile UX improvements.

---

## Version 2.1 - Mobile UX & Critical Bugfix (2025-01-27)

### Critical Bugfix: State Preservation

**Problem**: Webhook was destroying state data from previous workflow phases!

**Root Cause**: When `adw_build` was triggered with an auto-detected or explicit ADW ID, the webhook would:
1. Load existing state (containing `branch_name`, `plan_file`, `issue_class` from planning phase)
2. Call `state.update()` with ONLY `adw_id` and `issue_number`
3. Save the incomplete state, **overwriting** all the planning data
4. Result: Build phase fails with "No branch name in state"

**Example Failure Scenario**:
```
3:53 PM - Planning completes, saves full state ✅
4:21 PM - User posts "adw_build"
4:21 PM - Webhook auto-detects ID, loads state
4:21 PM - Webhook OVERWRITES state with partial data ❌
4:21 PM - Build starts, finds empty state ❌
         Error: "No branch name in state - run adw_plan.py first"
```

**Fix**: Check if state already has `branch_name` before saving:
```python
if provided_adw_id:
    state = ADWState(provided_adw_id)

    # Only save if this is a NEW workflow (no branch_name yet)
    # If branch_name exists, preserve the existing state!
    if not state.data.get("branch_name"):
        state.update(adw_id=provided_adw_id, issue_number=str(issue_number))
        state.save("webhook_trigger")
    else:
        # Existing state - don't touch it!
        print(f"Preserving existing state (branch: {state.data.get('branch_name')})")
```

**Impact**:
- ✅ `adw_build` now works correctly after `adw_plan`
- ✅ Multi-phase workflows preserve state
- ✅ Prevents "No branch name" errors
- ✅ Logged for debugging

---

### Auto-Detection of ADW IDs

**Problem**: When continuing work with `adw_build`, users had to manually copy/paste UUID from previous comments. On mobile devices, this is extremely difficult.

**Solution**: Automatic detection of ADW IDs from issue history!

#### Implementation Details

**New Function**: `find_latest_adw_id_in_issue(issue_number)` in `trigger_webhook.py`

Searches issue comments in reverse chronological order for ADW IDs using three robust patterns:
1. **JSON state dumps**: `"adw_id": "75de9bea-..."`
2. **Explicit mentions**: `adw_id: 75de9bea-...`
3. **Comment prefixes**: `75de9bea-..._sdlc_planner:`

#### User Experience

**Before**:
```
User: adw_build
Bot: ❌ Error: Missing ADW ID
User: *scrolls through comments on mobile*
User: *tries to copy UUID from comment*
User: *gives up and uses desktop*
```

**After**:
```
User: adw_build
Bot: 💡 Auto-detected ADW ID: 75de9bea-b0f3-4450-b093-3b009bc66238
     Proceeding with adw_build...
     ✅ [starts building]
```

#### Error Messages

When auto-detection fails (no previous plan found), users get helpful guidance:

```markdown
❌ Missing ADW ID

`adw_build` requires an ADW ID to know which plan to continue from.

**Usage:**
- `adw_build <adw_id>` (e.g., `adw_build 75de9bea`)
- Or: `adw_build: description` with `adw_id: <adw_id>` on a separate line

**Finding the ADW ID:**
Look for the "Final planning state" comment from the planning phase,
or any comment with `adw_id: ...` in it.

**Alternative:**
Use `adw_plan_build` instead - it creates a new plan and builds it automatically!
```

#### Benefits

1. **Mobile-First**: No more copying UUIDs on mobile devices
2. **Educational**: Error messages teach proper syntax
3. **Transparent**: Bot explains when auto-detection is used
4. **Backward Compatible**: Explicit IDs still work
5. **Smart**: Finds the LATEST plan, not old ones

#### Files Modified

- `adws/adw_triggers/trigger_webhook.py`:
  - Added `import re`
  - Added imports: `fetch_issue_comments`, `extract_repo_path`
  - Added function: `find_latest_adw_id_in_issue()` (~60 lines)
  - Enhanced validation logic with auto-detection (~40 lines)

---

## Version 2.0 - Critical Fixes Implemented (2025-01-27)

### 1. Shell Compatibility (High Priority) ✅

**Problem**: Commands used bash-specific syntax but macOS defaults to zsh, causing parse errors.

**Impact**: Users saw `(eval):1: parse error near ')'` when running commands directly in zsh.

**Solution**:
- Wrapped all multi-line bash commands in heredoc blocks: `bash << 'EOFSCRIPT' ... EOFSCRIPT`
- Replaced `source .env` with portable `grep/cut` extraction: `PORT=$(grep "^PORT=" .env | cut -d'=' -f2)`
- Added clear prerequisites warning about shell compatibility in setup guide

**Files Fixed**:
- `.claude/commands/afk_github/detect_next_port.md`
- `.claude/commands/afk_github/start_tailscale_funnel.md`
- `.claude/commands/afk_github/test_afk_github.md`
- `.claude/commands/afk_github/setup_github_webhook.md`
- `scripts/start_tailscale_funnel.sh`

### 2. Tailscale CLI Version Mismatch (High Priority) ✅

**Problem**: Old command syntax `tailscale funnel $PORT &` doesn't work with Tailscale v1.88+.

**Impact**: Users got error: `"the CLI for serve and funnel has changed"`

**Solution**:
- Updated to new CLI syntax: `tailscale funnel --bg $PORT`
- Added fallback for older versions
- Added version check and display in scripts
- Added Tailscale version requirement (v1.88+) to prerequisites

**Files Fixed**:
- `.claude/commands/afk_github/start_tailscale_funnel.md`
- `scripts/start_tailscale_funnel.sh`

### 3. Case-Sensitive Process Matching (Medium Priority) ✅

**Problem**: `grep -q Python` failed when process name was `python3.1`.

**Impact**: Test scripts incorrectly reported server as not running.

**Solution**: Changed to case-insensitive grep: `grep -iq python`

**Files Fixed**:
- `.claude/commands/afk_github/test_afk_github.md`

### 4. Bash Regex Portability (Medium Priority) ✅

**Problem**: Bash regex `[[ $VAR =~ pattern ]]` doesn't work reliably across different shell versions.

**Impact**: GitHub URL parsing failed silently in some environments.

**Solution**: Replaced bash regex with portable `sed/cut` pipelines:
```bash
# Old (bash-specific):
if [[ $GITHUB_REPO_URL =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
fi

# New (portable):
OWNER=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f1)
REPO=$(echo "$GITHUB_REPO_URL" | sed 's|.*github.com[:/]||' | cut -d'/' -f2 | sed 's|\.git$||')
```

**Files Fixed**:
- `.claude/commands/afk_github/test_afk_github.md`
- `.claude/commands/afk_github/setup_github_webhook.md`

---

## New Features Added

### 1. All-in-One Setup Script ✅

**Created**: `scripts/setup_afk_github_full.sh`

A comprehensive, single-command setup script that:
- ✅ Checks all prerequisites (gh, tailscale, claude, uv, jq)
- ✅ Detects available port automatically
- ✅ Configures GitHub repository
- ✅ Sets up environment variables
- ✅ Starts Tailscale funnel
- ✅ Creates GitHub webhook
- ✅ Starts webhook server
- ✅ Provides colored, step-by-step output
- ✅ Verifies each step before proceeding
- ✅ Displays comprehensive final summary

**Usage**:
```bash
bash scripts/setup_afk_github_full.sh
```

### 2. Reset Script ✅

**Created**: `scripts/reset_afk_github.sh`

A utility script to cleanly reset the AFK GitHub setup:
- Stops webhook server
- Stops Tailscale funnel
- Optionally clears logs
- Provides clear next steps

**Usage**:
```bash
bash scripts/reset_afk_github.sh
```

### 3. Enhanced Prerequisites Section ✅

**Added to**: `AFK_GITHUB_SETUP.md`

New comprehensive prerequisites section covering:
- Required tools with installation commands
- Shell compatibility warning and workarounds
- Tailscale version check instructions
- Clear explanation of why prerequisites matter

### 4. Verification Steps Between Phases ✅

**Added to**: `AFK_GITHUB_SETUP.md`

Added verification commands after each setup phase:
- Verify files copied correctly
- Verify dependencies installed
- Verify port configured
- Verify funnel running
- Verify server running
- Verify webhook created

Example:
```bash
# After port detection
grep "^PORT=" .env && echo "✅ Port configured" || echo "❌ Port not set"
```

### 5. Comprehensive Troubleshooting Section ✅

**Enhanced in**: `AFK_GITHUB_SETUP.md`

Added detailed troubleshooting for all common issues:
- Parse errors in zsh (with solution)
- Tailscale funnel command failures (with version update instructions)
- Webhook not receiving events (with diagnostic commands)
- Port already in use (with port detection steps)
- Process matching failures (explained the case-sensitivity fix)
- ADW not processing issues (with verification commands)
- Environment variable loading issues (with portable extraction)
- Funnel persistence problems (with --bg flag explanation)

Each issue includes:
- **Root cause** explanation
- **Solution** with exact commands
- **Verification** steps

---

## Documentation Improvements

### 1. Updated Quick Start Section

Changed from single-path setup to dual-path approach:

**Method 1**: Fully automated with `setup_afk_github_full.sh` (recommended)
**Method 2**: Claude Code guided setup (for troubleshooting)

### 2. Better Error Messages

All scripts now provide:
- Clear error messages with ❌ prefix
- Exact commands to fix the issue
- Context about what went wrong
- Next steps to continue

Example:
```bash
if [ -z "$PORT" ]; then
    echo "❌ PORT not set in .env"
    echo ""
    echo "Run this first:"
    echo "  Read and execute .claude/commands/afk_github/detect_next_port.md"
    exit 1
fi
```

### 3. Version History

Added version tracking to `AFK_GITHUB_SETUP.md`:
- v1.0 (2025-01-26): Initial release
- v2.0 (2025-01-27): Major improvements based on user feedback

---

## Files Modified

### Command Files Updated
1. `.claude/commands/afk_github/detect_next_port.md`
   - Wrapped in bash heredoc
   - Added cross-platform sed handling
   - Added verification step

2. `.claude/commands/afk_github/start_tailscale_funnel.md`
   - Updated to new Tailscale CLI syntax
   - Added version check
   - Added fallback for old versions
   - Improved error messages

3. `.claude/commands/afk_github/test_afk_github.md`
   - Fixed case-insensitive python grep
   - Replaced bash regex with sed/cut
   - Wrapped in bash heredoc
   - Added better error messages

4. `.claude/commands/afk_github/setup_github_webhook.md`
   - Replaced bash regex with sed/cut
   - Wrapped in bash heredoc
   - Improved error messages with next steps

### Scripts Updated
1. `scripts/start_tailscale_funnel.sh`
   - Updated to new Tailscale CLI syntax
   - Added version detection
   - Added fallback support
   - Improved error handling

### Scripts Created
1. `scripts/setup_afk_github_full.sh` (NEW)
   - Complete automated setup
   - 400+ lines of robust bash
   - Colored output
   - Step-by-step verification

2. `scripts/reset_afk_github.sh` (NEW)
   - Clean reset utility
   - Interactive log clearing
   - Clear next steps

### Documentation Updated
1. `AFK_GITHUB_SETUP.md`
   - Added prerequisites section (+50 lines)
   - Added dual-path quick start (+40 lines)
   - Enhanced troubleshooting (+150 lines)
   - Added verification steps (+40 lines)
   - Updated throughout for new scripts

---

## Testing Recommendations

Before releasing these changes, test the following scenarios:

### On macOS with zsh (default)
1. Run `setup_afk_github_full.sh` from scratch
2. Verify all commands work without switching to bash
3. Test reset and re-run setup

### On macOS with bash
1. Run `setup_afk_github_full.sh` from scratch
2. Verify backward compatibility

### With Old Tailscale Version
1. Test with Tailscale < v1.88
2. Verify fallback syntax works

### With New Tailscale Version
1. Test with Tailscale v1.88+
2. Verify --bg flag works

### Edge Cases
1. Port already in use → Should find next available
2. Missing ANTHROPIC_API_KEY → Should fail with clear message
3. Tailscale not running → Should fail with clear instructions
4. GitHub remote not set → Should fail with setup instructions

---

## Migration Guide (For Existing Users)

If you already have AFK GitHub set up with the old template:

1. **Pull the latest changes**:
   ```bash
   cd /path/to/afk-github-template
   git pull
   ```

2. **Copy updated files to your project**:
   ```bash
   # Update command files
   cp -r .claude/commands/afk_github /path/to/your-project/.claude/commands/

   # Update scripts
   cp scripts/start_tailscale_funnel.sh /path/to/your-project/scripts/
   cp scripts/setup_afk_github_full.sh /path/to/your-project/scripts/
   cp scripts/reset_afk_github.sh /path/to/your-project/scripts/
   chmod +x /path/to/your-project/scripts/*.sh

   # Update setup guide
   cp AFK_GITHUB_SETUP.md /path/to/your-project/
   ```

3. **No need to re-run setup** if already working - these are improvements for new setups

4. **Optional: Test the improvements**:
   ```bash
   cd /path/to/your-project
   bash scripts/test_afk_github.sh
   ```

---

## Acknowledgments

These improvements were identified and validated through real-world usage feedback from setting up AFK GitHub in a new project. Special thanks to the AI agent that documented each pain point with:
- Exact error messages
- Root cause analysis
- Proposed solutions
- Verification steps

This feedback loop demonstrates the value of dogfooding and iterative improvement.

---

## Future Improvements (Potential)

Based on this round of improvements, consider for future versions:

1. **Docker Support**: Containerize the webhook server for even easier setup
2. **Windows Support**: Test and document Windows/WSL setup
3. **Multi-Project Manager**: CLI tool to manage multiple AFK GitHub instances
4. **Health Dashboard**: Simple web UI to monitor webhook status
5. **Auto-Update**: Script to pull latest template improvements
6. **Integration Tests**: Automated tests for all setup scenarios

---

## Version Info

- **Previous Version**: 1.0 (Initial release)
- **Current Version**: 2.0 (Shell compatibility and usability improvements)
- **Lines Changed**: ~400 additions, ~100 deletions
- **Files Modified**: 8
- **Files Created**: 2
- **Backward Compatible**: Yes (existing setups continue to work)

---

**End of Improvements Document**
