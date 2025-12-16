# Global Claude Code Configuration - Changelog

This file contains the complete version history of the global Claude Code configuration system.

## December 15, 2025 - Token Usage Tracking for /log Command

**Changes:**
- Added step 7 to `/log` command for token usage tracking
- Created `~/.claude/logs/log-command-tokens.csv` for analysis
- CSV format: timestamp, project, tokens_used

**Impact:**
- Can now analyze average token consumption per `/log` invocation
- Data available for optimizing documentation workflows
- Easy analysis with awk/spreadsheet tools

**Files modified:**
- `~/.claude/commands/log.md` - Added token logging step

**Files created:**
- `~/.claude/logs/log-command-tokens.csv` - Token usage log (CSV)

---

## December 15, 2025 - Removed /save and /bye Commands (Non-functional)

**What happened:**
- Created `/save` and `/bye` commands to auto-document before exit/clear
- Discovered Claude Code cannot programmatically invoke `/clear` or `/exit`
- Commands were useless — moved to graveyard

**Lesson learned:**
- Slash commands can run `/log` but can't trigger CLI commands like `/clear` or `/exit`
- No hook-based solution exists for "auto-log before exit" with full LLM analysis

**Files moved to graveyard:**
- `~/projects/graveyard/claude-global/save.md`
- `~/projects/graveyard/claude-global/bye.md`

---

## December 12, 2025 - Homelab Twingate Systemd Migration & NIC Fix

**Summary:**
Major infrastructure changes to home lab Proxmox cluster - migrated Twingate connectors from LXC containers to native systemd services and fixed Intel NIC hardware hang bug.

**Problem Investigated:**
- prox-tower lost SSH and Proxmox web UI access twice (Dec 11 ~10:57 AM, Dec 12 ~11:28 AM)
- Root cause: Intel I218-LM onboard NIC experiencing hardware hangs (e1000e driver TSO bug)
- Twingate connector stuck in authentication loop since Dec 3 (connector was unregistered from admin console)

**Changes Made:**

Infrastructure:
- **prox-tower:** Added TSO/GSO/GRO disable to `/etc/network/interfaces`, installed Twingate systemd service, removed LXC 201 and Docker container
- **prox-book5:** Installed Twingate systemd service (via SSH from tower), removed LXC 200
- **Cluster-wide:** Renamed ZFS storage pools (`local-zfs` → `local-zfs-book5` / `local-zfs-tower`)

Documentation Updated:
- `docs/homelab.md` - Complete rewrite of Twingate section, added Known Issues section, added Pending Hardware Upgrades table
- `docs/ssh-access-cheatsheet.md` - Updated network diagram (systemd instead of LXC), fixed VM numbering (VM 101 not VM 102)

Files Created on prox-tower:
- `/root/twin-connect-systemd.md` - Twingate systemd setup instructions
- `/root/nic-upgrade-tplink-tx201.md` - Network card upgrade instructions

**Pending Hardware Upgrades:**
- CPU: Intel Xeon E5-2683 V4 (16 core, 40MB cache)
- NIC: TP-Link TX201 (2.5GbE, Realtek RTL8125)

**Impact:**
- Twingate connectors now more reliable (systemd vs Docker/LXC)
- Network stability improved with offloading disabled
- Storage naming clearer for multi-node cluster
- Documentation accurately reflects current infrastructure

---

## December 5, 2025 - Cross-Machine Conversation History Sync

**Changes:**
- Merged Claude Code conversation histories from Mac (1,286 conversations) and Server (122 conversations)
- Removed 127 duplicate conversations, resulting in 1,281 unique conversations sorted chronologically
- Removed `history.jsonl` from `.gitignore` to enable git tracking
- Created `claudegit` alias for syncing history before launching Claude Code
- Updated `.gitignore` on both Mac and Server to track history.jsonl
- Added Python merge script (`/tmp/merge-history.py`) for future manual history merges

**Impact:**
- Unified conversation history accessible from any machine
- No more "which machine did I have that conversation on?" confusion
- Automatic sync via hourly git backup system
- `claudegit` command pulls latest history before launching Claude

**Files created:**
- `/tmp/merge-history.py` - Python script to merge JSONL history files by timestamp

**Files modified:**
- `~/.claude/.gitignore` (Mac & Server) - Now tracks history.jsonl (commented out line 8)
- `~/.claude/history.jsonl` (Mac & Server) - Merged and synchronized (1,281 conversations)
- `~/projects/zshConfig/zshrc` (Mac) - Added `claudegit` alias at line 98
- `/root/.zshrc` (Server) - Added `claudegit` alias after existing aliases section

**Technical implementation:**
- History files merged by timestamp using Python script
- Duplicate detection based on (timestamp, project, display text)
- Git commit `e90bda7` pushed to `github.com:jaded423/claudeGlobal.git`
- Server initialized as git repo and pulled from GitHub
- Alias runs: `cd ~/.claude && git pull && cd - > /dev/null && claude`
- Hourly backup handles pushing new conversations to GitHub

**Workflow:**
1. Use Claude on any machine → conversation saved to local history.jsonl
2. Hourly backup commits and pushes to GitHub
3. On any other machine: `claudegit` pulls latest history before launching
4. All machines have access to complete conversation history

## November 23, 2025 - Grand Synchronization Project Phase 1 Complete

**Changes:**
- Created unified `homelab.md` documentation merging Mac and server versions
- Standardized all IP addresses to 192.168.2.x subnet (from mixed 192.168.1.x/192.168.2.x)
- Created `homelab-expansion.md` documenting infrastructure expansion plans
- Implemented automated GitHub → Server sync infrastructure
- Created `sync-project.md` documenting the grand synchronization project

**Impact:**
- Home lab documentation now consistent across both machines
- Automated hourly sync prevents documentation drift
- Clear roadmap for infrastructure expansion
- Foundation established for syncing all documentation

**Files created:**
- `docs/homelab-expansion.md` - Infrastructure expansion plans and checklist
- `docs/sync-project.md` - Grand synchronization project documentation
- `~/scripts/sync-claude-global.sh` (on server) - Sync script
- `~/.config/systemd/user/claude-sync.service` (on server) - Systemd service
- `~/.config/systemd/user/claude-sync.timer` (on server) - Hourly timer

**Files modified:**
- `docs/homelab.md` - Unified with correct 192.168.2.x network
- `CLAUDE.md` - Added references to new documentation files

**Technical implementation:**
- Mac pushes to GitHub hourly via existing gitBackup.sh
- Server pulls from GitHub hourly via new systemd timer
- Conflict resolution: Server hard resets to origin (Mac is source of truth)
- Successfully tested end-to-end sync workflow

## November 14, 2025 - [MINOR] Documentation System Enhancements

**Changes**:
- Created template system with 3 starter templates
- Implemented documentation dashboard with health metrics
- Added enhanced skills: doc-optimizer and session-historian
- Enhanced /init command to use templates
- Added doc-check and doc-metrics functions to .zshrc
- Improved interconnections.md with visual dependency graphs
- Created detect-context command for machine awareness
- Standardized changelog format with semantic versioning

**Impact**:
- Improved documentation consistency across projects
- Real-time documentation health monitoring
- Better dependency visualization and understanding
- Automated context detection for appropriate workflows

## November 7, 2025 - [MAJOR] System-Wide Lean Documentation Structure Refactoring

**Major Changes**: Refactored all project CLAUDE.md files to follow a lean structure pattern with `docs/` subdirectories, establishing a consistent documentation standard across the entire system.

**Projects Refactored** (9 total):
1. **promptLibrary** - 222 lines → 147 lines main file + 5 docs files
2. **nvimConfig** - 804 lines → 144 lines main file + 5 docs files
3. **odooReports** - 789 lines → 257 lines main file + 4 docs files
4. **scripts** - 445 lines → 128 lines main file + 5 docs files
5. **dotfilesPrivate** - 239 lines → 93 lines main file + 4 docs files
6. **graveyard** - 90 lines → 75 lines main file + 1 docs file
7. **n8nDev** - 400 lines → 98 lines main file + 6 docs files
8. **n8nProd** - 445 lines → 73 lines main file + 7 docs files
9. **Global ~/.claude/** - Already using this pattern (template for others)

**New Standard Structure**:

Main CLAUDE.md (100-150 lines):
- Overview and purpose
- Directory structure
- Quick reference with essential commands
- Links to detailed docs: `**📚 Detailed Documentation**: See docs/`
- Version requirements
- Reference to changelog: `**Full changelog**: [docs/changelog.md](docs/changelog.md)`

docs/ subdirectory with specialized files:
- **architecture.md** - Technical design, system components, implementation details
- **workflows.md** - Development workflows, common tasks, how-tos
- **commands.md** - Comprehensive command reference (when applicable)
- **troubleshooting.md** - Common issues and solutions
- **changelog.md** - Complete version history (ready for `/sum` archiving)
- **Additional project-specific files** - integrations.md, configuration.md, backup.md, etc.

**Documentation Added to Global CLAUDE.md**:
- Added "Lean CLAUDE.md Structure for `/init`" section to User Preferences
- Includes complete pattern specification with example markdown
- Documents benefits: manageable size, topic organization, easier maintenance
- Lists all 9 projects already using this pattern

**Impact**:

Immediate Benefits:
- **82% average reduction** in main file size (nvimConfig: 804→144 lines)
- **Consistent navigation** - users know exactly where to find information
- **Easier maintenance** - smaller, focused files reduce merge conflicts
- **Better organization** - architecture separate from workflows separate from troubleshooting
- **Multi-AI compatible** - works seamlessly with CLAUDE.md/GEMINI.md/AGENTS.md symlinks

Long-term Benefits:
- **Scalability** - projects can grow documentation without bloating main file
- **`/sum` compatibility** - changelog.md can be archived separately when it gets large
- **Onboarding** - new developers can quickly scan main file, dive deep as needed
- **Future `/init`** - all new projects will automatically use this structure

**Files Modified**:

Global Configuration:
- `~/.claude/CLAUDE.md` - Added lean structure pattern documentation to User Preferences

Project Main Files (refactored to lean structure):
- `~/projects/promptLibrary/CLAUDE.md`
- `~/projects/nvimConfig/CLAUDE.md`
- `~/projects/odooReports/CLAUDE.md`
- `~/projects/scripts/CLAUDE.md`
- `~/projects/dotfilesPrivate/CLAUDE.md`
- `~/projects/graveyard/CLAUDE.md`
- `~/projects/n8nDev/CLAUDE.md`
- `~/projects/n8nProd/CLAUDE.md`

New Documentation Files Created (37 total):
- promptLibrary: docs/architecture.md, workflows.md, changelog.md
- nvimConfig: docs/architecture.md, commands.md, workflows.md, troubleshooting.md, changelog.md
- odooReports: docs/architecture.md, workflows.md, troubleshooting.md, changelog.md
- scripts: docs/architecture.md, configuration.md, workflows.md, troubleshooting.md, changelog.md
- dotfilesPrivate: docs/architecture.md, workflows.md, troubleshooting.md, changelog.md
- graveyard: docs/changelog.md
- n8nDev: docs/architecture.md, commands.md, workflows.md, integrations.md, troubleshooting.md, changelog.md
- n8nProd: docs/architecture.md, commands.md, workflows.md, integrations.md, backup.md, troubleshooting.md, changelog.md

**Rationale**:

The global `~/.claude/` documentation already used this lean pattern successfully (CLAUDE.md + docs/ subdirectory). Extending this pattern to all projects provides:

1. **Consistency** - Same structure everywhere reduces cognitive load
2. **Discoverability** - Know where to look for specific information
3. **Maintainability** - Update individual topics without touching main file
4. **Future-proofing** - `/init` command now documented to create this structure automatically

**Standard Established**: All future projects initialized with `/init` will automatically follow this lean documentation pattern, preventing the need for future refactoring.

## November 6, 2025 - [MINOR] Removed Auto-Commit from `/log` Command

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

## November 6, 2025 - [MINOR] odooReports Phase 1 Complete + Graveyard System

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

## November 5, 2025 - [MAJOR] Moved Global Config to Version Control with Automated Backups

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
