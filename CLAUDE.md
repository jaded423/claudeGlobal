# Global Claude Code Documentation System

This file documents the global Claude Code configuration and slash commands available across **all projects**.

## Overview

This directory (`~/.claude/`) contains global configuration and commands that work with Claude Code across any project you're working on - whether it's Python, SQL, JavaScript, Neovim configs, or any other codebase.

**📚 Detailed Documentation**: For comprehensive information, see the `~/.claude/docs/` directory:
- **[projects.md](docs/projects.md)** - Detailed descriptions of all active projects
- **[interconnections.md](docs/interconnections.md)** - System dependency map and file movement checklists
- **[troubleshooting.md](docs/troubleshooting.md)** - Solutions for common issues

## User Preferences

**Autonomous Workflow Execution**: When the user invokes documented workflows (like `/init`, `/sum`, custom commands), **ALWAYS execute the complete workflow autonomously** without asking ANY questions:

- ✅ **DO**: Execute ALL steps automatically including git init, GitHub repo creation, and backup integration
- ✅ **DO**: Create files, symlinks, run git operations, push to GitHub
- ❌ **DON'T**: Ask "Should I create CLAUDE.md?" when user typed `/init`
- ❌ **DON'T**: Ask "Should I create symlinks?" - they're part of `/init` workflow
- ❌ **DON'T**: Ask "Should I initialize git?" - YES, always initialize
- ❌ **DON'T**: Ask "Should I create a GitHub remote?" - YES, always create and push
- ❌ **DON'T**: Request permission for ANY step in a documented workflow

**Rationale**: If the user types `/init`, they know what `/init` does and want the COMPLETE autonomous workflow:
1. Create CLAUDE.md documentation
2. Create GEMINI.md and AGENTS.md symlinks
3. Run `git init` (always, even if not a git repo yet)
4. Create GitHub remote repository (private)
5. Push initial commit
6. Add repo to automated backup system in `~/scripts/dotfiles_backup.sh`
7. Inform user that hourly backups are now active for this repo

**Exception**: Only ask questions for genuinely ambiguous technical decisions (e.g., "Which authentication method?" when multiple valid approaches exist).

**Email Testing Policy**: When testing ANY code that sends emails (across all projects), **ONLY send test emails to joshua@elevatedtrading.com**:

- ✅ **DO**: Comment out all other recipients before testing
- ✅ **DO**: Add clear TODO comments to uncomment for production
- ✅ **DO**: Document this in testing sections of project docs
- ❌ **DON'T**: Send test emails to stakeholders, clients, or CEO
- ❌ **DON'T**: Send test emails to any production distribution lists

**Example**:
```python
# TESTING: Only send to joshua during development/testing
# TODO: Uncomment all recipients before production deployment
RECIPIENTS = [
    # "ceo@company.com",           # Uncomment for production
    # "stakeholder@company.com",   # Uncomment for production
    "joshua@elevatedtrading.com"
]
```

**Rationale**: Test emails should never reach stakeholders, clients, or executives. Only the developer (joshua) should receive test notifications.

## Directory Structure

```
~/.claude/
├── CLAUDE.md           # This file - global documentation (source of truth)
├── GEMINI.md           # Symlink → CLAUDE.md (for Google Gemini)
├── AGENTS.md           # Symlink → CLAUDE.md (for other AI assistants)
├── commands/           # Global slash commands (available in all projects)
│   ├── sum.md          # Summarize/archive documentation
│   └── log.md          # Document session changes
├── docs/               # Detailed documentation
│   ├── projects.md     # All active projects overview
│   ├── interconnections.md  # System dependency map
│   ├── troubleshooting.md   # Common issues and solutions
│   └── project-logs/   # Detailed session logs per project
├── agents/             # AI agent definitions
├── skills/             # Reusable skills
├── settings.json       # Global Claude Code settings
└── [other system files]
```

## Global Slash Commands

### `/sum` - Summarize & Archive

Summarizes and archives changelog history, creating lean documentation files.

**Usage**: Run monthly or when docs get too large
```bash
/sum
# → Archives to backups/CLAUDE-[timestamp].md
# → Creates clean version without old changelogs
```

### `/statusline` - Configure Status Line

Configures Claude Code's status line based on your shell PS1 prompt.

**Usage**: After changing your shell prompt configuration
```bash
/statusline
# → Reads ~/.zshrc or ~/.bashrc
# → Configures Claude Code to match your prompt
```

### `/init` - Initialize Project Documentation

**FULLY AUTONOMOUS** - Analyzes codebase, creates docs, initializes git, creates GitHub repo, pushes, and adds to automated backups.

**What it does** (all automatically):
1. Analyzes codebase structure and architecture
2. Creates CLAUDE.md with project-specific guidance
3. Creates GEMINI.md and AGENTS.md symlinks
4. Runs `git init` (if not already a repo)
5. Commits documentation files
6. Creates private GitHub repository and pushes
7. Adds repo to `~/scripts/dotfiles_backup.sh` REPOS array
8. Commits and pushes updated backup script
9. Informs user: "✅ Project initialized! GitHub repo created and added to hourly automated backups."

**NO questions asked** - typing `/init` means you want the complete workflow.

### `/log` - Document Session Changes

**AUTONOMOUS** - Claude documents what Claude did during the session.

**What it does**:
1. Analyzes git changes and recalls what Claude did this session
2. Autonomously writes detailed changelog to project CLAUDE.md
3. Updates `~/.claude/docs/projects.md` with brief summary
4. Saves changes locally (no commit - hourly backup handles that)

**Usage**: Run at the end of a session to document Claude's work
```bash
/log
# → Claude analyzes what IT changed
# → Updates project CLAUDE.md (detailed)
# → Updates global docs/projects.md (brief)
# → Changes saved locally, hourly backup commits with AI message
```

**Use case**: This documents **Claude's changes**, not your manual edits. If you make changes yourself, document those yourself. This is for when Claude Code makes changes and you want those changes documented in the appropriate places.

**Documentation layers**:
- **Project CLAUDE.md** - Detailed changelog with dates, impacts, file references
- **Global docs/projects.md** - Brief "Recent Changes" and "Last Updated" for cross-project awareness
- **Global CLAUDE.md** - Only updated for major architectural changes

**Philosophy**: Keeps global Claude aware of what each project does and needs, while maintaining detailed history in project docs. Changes accumulate locally until hourly backup creates AI-generated commit messages with full context.

## Active Projects Quick Reference

For detailed project information, see **[docs/projects.md](docs/projects.md)**.

**Currently active projects**:
1. **promptLibrary** - AI prompt engineering library with testing
2. **nvimConfig** - Neovim configuration (symlinked to `~/.config/nvim`)
3. **dotfilesPrivate** - ZSH shell config (symlinked to `~/.zshrc`)
4. **odooReports** - Business automation for Elevated Trading
5. **scripts** - Automation infrastructure (backup system, email)
6. **Elevated Vault** - Obsidian knowledge base in Google Drive
7. **n8nDev** - n8n development environment (Docker, port 5678)
8. **n8nProd** - n8n production environment (Docker, port 5679)
9. **graveyard** - Obsolete file archive (6-month retention)

All projects have hourly automated backups to GitHub.

## Graveyard - Obsolete File Archive

**Location**: `~/projects/graveyard/`

The graveyard is a holding area for obsolete and questionable files from all projects. Instead of deleting immediately, move files here for 6-month retention, providing a safety net for reference.

**When to use**:
- Cleaning up project directories
- Removing outdated test scripts
- Archiving old configuration files
- Preserving files "just in case"

**Structure**:
```
graveyard/
├── CLAUDE.md              # Documentation with log
├── odooReports/           # Files from odooReports project
├── nvimConfig/            # Files from nvimConfig project
└── [projectName]/         # Create subdirs per source project
```

**Usage**:
```bash
# Move obsolete files
mv old_file.py ~/projects/graveyard/projectName/

# Log the move in graveyard/CLAUDE.md
```

**Deletion policy**: Files older than 6 months can be permanently deleted. User handles manual cleanup.

See `~/projects/graveyard/CLAUDE.md` for full log of archived files.

## System Interconnections

**⚠️ BEFORE MOVING ANY FILES**, consult **[docs/interconnections.md](docs/interconnections.md)**.

**Critical dependencies to be aware of**:
- **Symlinks**: `~/.config/nvim`, `~/.zshrc`, `~/.p10k.zsh`, `~/scripts`
- **LaunchAgents**: 3 background jobs (dotfiles backup, email reminder, claude auto)
- **Crontab**: 2 scheduled tasks (Odoo reports, claude auto reset)
- **Gmail OAuth**: Shared credentials in `~/projects/odooReports/AR_AP/`
- **Python 3.13**: Hardcoded paths in 3+ automation scripts
- **SSH Keys**: Must be in macOS Keychain for automated git push

**Quick check before moving files**:
```bash
# What uses this directory/file?
grep -r "path/to/check" ~/.claude/docs/interconnections.md
```

## Multi-AI Documentation System

### The Three Files (via Symlinks)

Every project should have these three documentation files in its root:

1. **CLAUDE.md** - Source of truth
   - Primary documentation file
   - Updated during development
   - Contains changelog entries

2. **GEMINI.md** - Symlink to CLAUDE.md
   - Automatically stays in sync via filesystem symlink
   - Used when working with Google Gemini AI

3. **AGENTS.md** - Symlink to CLAUDE.md
   - Automatically stays in sync via filesystem symlink
   - Used for other AI assistants

**Benefits of Symlinks**:
- Always in sync - no manual sync commands needed
- Single source of truth - edit CLAUDE.md only
- Git-friendly - commit symlinks once, never out of sync

### Workflow

**Regular Development**:
```bash
# Just edit CLAUDE.md directly
vim CLAUDE.md
# → GEMINI.md and AGENTS.md automatically reflect changes via symlinks
```

**Manual Summarizing**:
```bash
# When docs get too large:
/sum
# → Archives: backups/CLAUDE-[timestamp].md
# → Summarizes: CLAUDE.md (removes old changelogs)
```

## Setting Up a New Project

**Recommended: Use `/init` command** - handles everything automatically.

**Manual setup** (if needed):
```bash
cd ~/projects/my-new-project

# Create symlinks
ln -s CLAUDE.md GEMINI.md
ln -s CLAUDE.md AGENTS.md

# Add to .gitignore
echo "backups/" >> .gitignore

# Initialize git and create GitHub repo
git init
git add .
git commit -m "Initial commit: Add multi-AI documentation"
gh repo create my-new-project --private --source=. --remote=origin --push
```

## Permissions Configuration

Auto-approve specific operations to streamline workflows. Configured in `settings.json`:

**Current auto-approved operations**:
- **Read files**: `Read(*)`, `cat`, `readlink` - Read anything, anywhere
- **Search/Discovery**: `Grep(*)`, `Glob(*)`, `find`, `ls`
- **Cross-project access**: Can read from `~/scripts` and `~/projects`
- **Symlink creation**: `ln -s` in `~/projects/*` directories
- **Creating new markdown files**: `Write(*.md)`
- **Git operations**: `git status`, `git remote`, `git init`, `git add`, `git commit`, `git push`
- **GitHub repo creation**: `gh repo create` (private repos)

**Still requires approval**:
- **Editing existing files** - you control all changes
- **Deleting files or directories**
- **Other bash commands** not explicitly listed

## Troubleshooting

For detailed troubleshooting, see **[docs/troubleshooting.md](docs/troubleshooting.md)**.

**Quick fixes**:

**Commands not found**:
```bash
ls ~/.claude/commands/  # Should show sum.md and log.md
```

**Symlinks broken**:
```bash
ls -la | grep -E "(GEMINI|AGENTS).md"
readlink GEMINI.md  # Should output: CLAUDE.md
```

**Automation not working**:
```bash
launchctl list | grep user  # Check launchd jobs
crontab -l  # Check cron jobs
```

## Best Practices

### Changelog Entry Guidelines
- **Be specific**: Include file paths and line numbers
- **Explain why**: Not just what changed, but why it matters
- **Include impact**: How does this affect the project?
- **Use examples**: Show concrete examples when helpful
- **Keep it concise**: 3-5 bullet points is usually enough

### Git Workflow
```bash
# 1. Make changes to your code
vim src/api.py

# 2. Document changes in CLAUDE.md
vim CLAUDE.md

# 3. Commit everything together
git add .
git commit -m "feat: Add user authentication"
git push
```

### Backup Management
- Backups live in `backups/` directory (gitignored)
- Never deleted automatically
- Can reference historical context anytime
- Organized by timestamp (YYYY-MM-DD-HH-MM-SS)

## Version History

### November 6, 2025 - Removed Auto-Commit from `/log` Command

**Changes:**
- Modified `/log` command to remove all git operations (commands/log.md)
- `/log` now only updates documentation files, does not commit or push
- Changed workflow: documentation updates saved locally, hourly backup handles commits
- Updated command guidelines to reflect new "No auto-commit" policy
- Modified example workflows to show changes saved without commit/push

**Impact:**
- Dramatically reduces commit frequency (from 97 commits in November to ~24/month)
- AI-generated commit messages now have better context from accumulated changes
- Multiple sessions' changes batched into single meaningful commits
- Hourly backup script's AI summary can analyze larger diffs for better messages
- Commit history becomes more readable and meaningful

**Files modified:**
- `~/.claude/commands/log.md` - Removed steps 7-8 about git operations, updated guidelines

**Rationale:**
User was committing every time they ran `/log`, resulting in 97 commits in November alone. With hourly backups now using AI-generated commit messages via Claude Haiku API, it's better to let changes accumulate between sessions so the AI has more context for meaningful commit messages.

### November 6, 2025 - odooReports Phase 1 Complete + Graveyard System

**Changes:**
- Completed Phase 1: Docker containerization for odooReports (hybrid n8n architecture)
- Created graveyard system at `~/projects/graveyard/` for obsolete file archival (6-month retention)
- Added global email testing policy: tests only to joshua@elevatedtrading.com
- Cleaned up odooReports: removed 7 obsolete files, 38 PDF backups, streamlined AR/AP report

**Impact:**
- odooReports ready for Phase 2 (n8n workflows)
- Graveyard available for all future project cleanups
- Email testing policy prevents stakeholder spam across all projects
- Container uses volume mounts - edit host code, container sees changes instantly

**Files:**
- `~/projects/graveyard/CLAUDE.md` - Graveyard log and documentation
- `~/projects/odooReports/Dockerfile`, `docker-compose.yml` - Container setup
- Updated User Preferences with email testing policy

### November 5, 2025 - Moved Global Config to Version Control with Automated Backups

**Changes:**
- **Moved `~/.claude` to `~/projects/.claude`** for version control
- **Created symlink** `~/.claude` → `~/projects/.claude` (Claude Code continues to work normally)
- **Merged settings.local.json** - Added `Bash(zsh:*)` permission from pre-existing file
- **Created .gitignore** - Excludes session data (debug/, file-history/, todos/, projects/)
- **Initialized git repository** - Tracking essential config files only (15 files)
- **Created GitHub repository** - Private repo at `github.com/jaded423/claudeGlobal`
- **Added to automated backups** - Updated `~/scripts/dotfiles_backup.sh` to include Claude Global
- **Created `/log` command** - Autonomous documentation of Claude's session changes
- **Created `docs/project-logs/`** - Directory structure for detailed cross-project session logs

**Impact:**
- Global Claude Code configuration now version controlled and backed up hourly
- All global documentation, agents, commands, and settings protected
- `/log` command enables automatic documentation of Claude's work across all projects
- Symlink approach means zero disruption to Claude Code functionality
- Now backing up 6 repositories total (added Claude Global to the list)

**Files created:**
- `.gitignore` - Excludes session-specific data
- `commands/log.md` - Autonomous session documentation command
- `docs/project-logs/README.md` - Directory for cross-project logs

**Files modified:**
- `CLAUDE.md` - Updated directory structure, added `/log` documentation
- `~/scripts/dotfiles_backup.sh` - Added Claude Global to REPOS array (line 14)
- `settings.local.json` - Merged `Bash(zsh:*)` permission

**Git/GitHub:**
- Repository: `github.com/jaded423/claudeGlobal`
- Initial commit: "Initial commit: Global Claude Code configuration"
- Subsequent commits: `/log` command creation and updates

**Rationale:**
Global configuration is critical infrastructure that should be version controlled and backed up. Moving to `~/projects/.claude` with symlink provides best of both worlds: version control + Claude Code compatibility. The `/log` command ensures Claude's work is properly documented across the entire system.

### November 4, 2025 - Documentation Restructure for Efficiency

**Changes:**
- **Restructured documentation** to prevent hallucinations and improve efficiency
- **Created `~/.claude/docs/` directory** for detailed documentation
- **Extracted detailed sections** into separate files:
  - `docs/projects.md` - All active project descriptions
  - `docs/interconnections.md` - System dependency map and movement checklists
  - `docs/troubleshooting.md` - Common issues and solutions
- **Compacted main CLAUDE.md** from 1100+ lines to ~300 lines
- **Added clear references** to detailed docs throughout main file
- Main file now focuses on: overview, user preferences, slash commands, quick references

**Impact:**
- Reduced token usage for context loading
- Easier to scan and find information quickly
- Less prone to hallucinations with smaller context
- Detailed information still accessible when needed
- Better organization for maintaining documentation

**Rationale:**
Large context files (1000+ lines) increase hallucination risk and make it harder for Claude to focus on relevant information. By splitting into focused documents, each interaction uses only necessary context.

### November 4, 2025 - Comprehensive Auto-Approval Permissions for Frictionless /init
- Added comprehensive permissions configuration to `settings.json`
- Auto-approve reading ANY file ANYWHERE
- Auto-approve all search operations
- Auto-approve git operations and GitHub repo creation
- Result: `/init` workflow now COMPLETELY frictionless - zero permission prompts

### November 4, 2025 - User Preferences for Fully Autonomous Execution
- Added User Preferences section documenting completely autonomous workflow execution
- `/init` workflow now includes end-to-end automation: from empty directory → documented → version controlled → backed up hourly
- NO questions asked except for genuinely ambiguous technical decisions

### November 3, 2025 - Major Documentation Expansion
- Added comprehensive Skills documentation section
- Added Global Agents documentation
- Expanded Global Slash Commands section
- Added Settings Configuration section
- Enhanced Troubleshooting section

### November 3, 2025 - Switched to Symlinks
- Removed `/sync-ai-docs` command (no longer needed)
- Switched from file copying to symlinks for GEMINI.md and AGENTS.md
- Simplified workflow - no manual sync commands required

## Resources

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [Slash Commands Guide](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Project Documentation](https://docs.claude.com/en/docs/claude-code/project-docs)
- **[Detailed Project Info](docs/projects.md)** - All active projects
- **[System Interconnections](docs/interconnections.md)** - Dependency map
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common issues
