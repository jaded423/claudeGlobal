# Global Claude Code Configuration - Changelog

This file contains the complete version history of the global Claude Code configuration system.

## November 6, 2025 - Removed Auto-Commit from `/log` Command

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
User was committing every time they ran `/log`, resulting in 97 commits in November alone. With hourly backups now using AI-generated commit messages via Claude Sonnet API, it's better to let changes accumulate between sessions so the AI has more context for meaningful commit messages.

## November 6, 2025 - odooReports Phase 1 Complete + Graveyard System

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

## November 5, 2025 - Moved Global Config to Version Control with Automated Backups

**Changes:**
- **Moved `~/.claude` to `~/projects/.claude`** for version control
- **Created symlink** `~/.claude` → `~/projects/.claude` (Claude Code continues to work normally)
- **Merged settings.local.json** - Added `Bash(zsh:*)` permission from pre-existing file
- **Created .gitignore** - Excludes session data (debug/, file-history/, todos/, projects/)
- **Initialized git repository** - Tracking essential config files only (15 files)
- **Created GitHub repository** - Private repo at `github.com/jaded423/claudeGlobal`
- **Added to automated backups** - Updated `~/scripts/gitBackup.sh` to include Claude Global
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
- `~/scripts/gitBackup.sh` - Added Claude Global to REPOS array (line 14)
- `settings.local.json` - Merged `Bash(zsh:*)` permission

**Git/GitHub:**
- Repository: `github.com/jaded423/claudeGlobal`
- Initial commit: "Initial commit: Global Claude Code configuration"
- Subsequent commits: `/log` command creation and updates

**Rationale:**
Global configuration is critical infrastructure that should be version controlled and backed up. Moving to `~/projects/.claude` with symlink provides best of both worlds: version control + Claude Code compatibility. The `/log` command ensures Claude's work is properly documented across the entire system.

## November 4, 2025 - Documentation Restructure for Efficiency

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

## November 4, 2025 - Comprehensive Auto-Approval Permissions for Frictionless /init

**Changes:**
- Added comprehensive permissions configuration to `settings.json`
- Auto-approve reading ANY file ANYWHERE
- Auto-approve all search operations
- Auto-approve git operations and GitHub repo creation

**Impact:**
- `/init` workflow now COMPLETELY frictionless - zero permission prompts
- Streamlined development workflow across all projects

## November 4, 2025 - User Preferences for Fully Autonomous Execution

**Changes:**
- Added User Preferences section documenting completely autonomous workflow execution
- `/init` workflow now includes end-to-end automation: from empty directory → documented → version controlled → backed up hourly
- Established policy: NO questions asked except for genuinely ambiguous technical decisions

**Impact:**
- Clear expectations for autonomous behavior
- Eliminated unnecessary confirmation prompts
- Faster workflow execution

## November 3, 2025 - Major Documentation Expansion

**Changes:**
- Added comprehensive Skills documentation section
- Added Global Agents documentation
- Expanded Global Slash Commands section
- Added Settings Configuration section
- Enhanced Troubleshooting section

**Impact:**
- More comprehensive documentation for all Claude Code features
- Better guidance for customization and configuration

## November 3, 2025 - Switched to Symlinks

**Changes:**
- Removed `/sync-ai-docs` command (no longer needed)
- Switched from file copying to symlinks for GEMINI.md and AGENTS.md
- Simplified workflow - no manual sync commands required

**Impact:**
- Automatic synchronization through filesystem symlinks
- Eliminated manual sync step from workflow
- Single source of truth maintained automatically
