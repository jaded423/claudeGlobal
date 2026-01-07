# Global Claude Code Configuration - Changelog

This file contains the complete version history of the global Claude Code configuration system.

## 2026-01-07 - PC WSL Fixes and nvim Downgrade

**What changed:**
- Fixed WSL startup error by removing invalid Z: drive mount from `/etc/fstab`
- Installed ascii-image-converter to `/usr/local/bin/` for nvim snacks dashboard
- Downgraded nvim from 0.12.0-dev to 0.11.5 (AppImage at `~/.local/bin/nvim`)
- Pinned nvim-treesitter to commit 42fc28ba (master branch, matches Mac)
- Updated snacks.lua to use `vim.fn.exepath()` for cross-platform binary lookup
- Created convenience symlinks: `~/C` → `/mnt/c`, `~/Documents` → `/mnt/c/Users/joshu/Documents`
- Added `~/.local/bin` to PATH in `~/.zshenv`
- Added ls alias to suppress Windows system file permission errors

**Why:**
- fstab had stale Z: drive mount causing "mount -a failed" on WSL startup
- nvim 0.12.0-dev (nightly) had breaking changes with treesitter
- snacks dashboard couldn't find ascii-image-converter (PATH issue in spawned shells)
- Needed quick access to Windows C: drive and Documents from WSL

**Technical notes:**
- nvim 0.11.5 installed via AppImage, takes precedence over apt-installed 0.12-dev
- nvim-treesitter removed `configs.lua` module in main branch; pinned to last master commit
- Windows system files (hiberfil.sys, pagefile.sys, etc.) cause permission errors in WSL - normal behavior
- `vim.fn.exepath()` resolves full binary path at runtime, works cross-platform

**PC now has:**
- nvim 0.11.5 (matches Mac)
- ascii-image-converter for dashboard snake art
- Symlinks: ~/C, ~/Documents
- Clean ls output (suppresses permission errors)

---

## 2026-01-07 - Updated Claude Configuration and Image Cache Cleanup

**What changed:**
- Updated shell configuration to explicitly use zsh instead of bash in CLAUDE.md
- Removed three image cache files (1.png, 2.png, 3.png) from the image-cache directory
- Updated lastUpdated timestamp in plugins/known_marketplaces.json

**Why:**
- Clarified that all systems use zsh, ensuring proper configuration file updates
- Cleaned up stale image cache entries that are no longer needed
- Updated marketplace plugin timestamp to reflect recent changes

**Files modified:**
- `CLAUDE.md` - Added shell configuration note
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/1.png` - Deleted
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/2.png` - Deleted
- `image-cache/df22ef64-0bdf-47fa-a3eb-ac2b1c6b5fc7/3.png` - Deleted
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp

---


## 2026-01-07 - PC WSL Fixes and nvim Downgrade

**What changed:**
- Fixed WSL startup error by removing invalid Z: drive mount from `/etc/fstab`
- Installed ascii-image-converter to `/usr/local/bin/` for nvim snacks dashboard
- Downgraded nvim from 0.12.0-dev to 0.11.5 (AppImage at `~/.local/bin/nvim`)
- Pinned nvim-treesitter to commit 42fc28ba (master branch, matches Mac)
- Updated snacks.lua to use `vim.fn.exepath()` for cross-platform binary lookup
- Created convenience symlinks: `~/C` → `/mnt/c`, `~/Documents` → `/mnt/c/Users/joshu/Documents`
- Added `~/.local/bin` to PATH in `~/.zshenv`
- Added ls alias to suppress Windows system file permission errors

**Why:**
- fstab had stale Z: drive mount causing "mount -a failed" on WSL startup
- nvim 0.12.0-dev (nightly) had breaking changes with treesitter
- snacks dashboard couldn't find ascii-image-converter (PATH issue in spawned shells)
- Needed quick access to Windows C: drive and Documents from WSL

**Files modified:**
- `docs/changelog.md` - Added detailed entry for WSL fixes
- `docs/machine-context.md` - Added Windows PC entry to machine table
- `docs/projects.md` - Updated nvimConfig and zshConfig entries with PC sync info

---


## 2026-01-07 - Synced nvim and zsh Configs to Windows PC (WSL)

**What changed:**
- Copied full nvim config from Mac to PC (`~/.config/nvim/`)
- Upgraded nvim on PC from 0.9.5 to 0.12.0 (via neovim-ppa/unstable)
- Installed deno and built peek.nvim for markdown preview
- Installed fd-find (symlinked as `fd`) and ripgrep for telescope.nvim
- Copied and adapted zshrc from Mac to PC with Linux-specific changes
- Created `~/.zsh/functions/` on PC with adapted function files:
  - `claude.zsh` - Claude Code wrapper
  - `fzf.zsh` - FZF config (pbcopy → xclip)
  - `ssh-functions.zsh` - SSH machine aliases
  - `git-functions.zsh` - gitall, commits (date -v → date -d)
  - `utils.zsh` - docxdiff, xlsxdiff
- Copied p10k.zsh config for consistent prompt styling
- Installed powerlevel10k in oh-my-zsh custom themes

**Why:**
- User wanted consistent development environment across Mac and PC
- Telescope.nvim requires fd and rg for file finding
- peek.nvim requires deno for markdown preview
- zsh functions needed Linux adaptations (clipboard, date syntax)

**Technical notes:**
- PC access via `ssh pc` (configured in earlier session via Twingate)
- Mac-specific items removed: brew plugin, macos plugin, homebrew paths, Vault path
- Linux adaptations: `pbcopy` → `xclip -selection clipboard`, `date -v-1d` → `date -d "1 day ago"`
- fd-find on Ubuntu installs as `fdfind`, symlinked to `~/.local/bin/fd`

**PC now has:**
- nvim 0.12.0 with full plugin config
- zsh with oh-my-zsh + powerlevel10k
- Same prompt styling as Mac
- SSH aliases (book5, tower, omarchy, ubuntu)
- Git status functions (gitall, commits)

---

## January 6, 2026 - Documentation System Overhaul

**Summary:**
Major restructure of homelab documentation and revamp of /log command to prevent future doc bloat.

**What changed:**

1. **Homelab Documentation Restructure:**
   - Reduced homelab.md from 2,282 lines to 271 lines (88% reduction)
   - Created `docs/homelab/` subdirectory with 6 detailed reference files:
     - `services.md` (295 lines) - Full service configurations
     - `troubleshooting.md` (344 lines) - Complete troubleshooting guide
     - `setup-guides.md` (173 lines) - Installation procedures
     - `gpu-passthrough.md` (192 lines) - Quadro M4000 passthrough docs
     - `google-drive.md` (174 lines) - rclone FUSE mount configuration
     - `media-server.md` (142 lines) - Plex/Jellyfin organization
   - Archived original to `docs/backups/homelab-20260106-*.md`

2. **Revamped /log Command:**
   - Smart routing: current state → CLAUDE.md, details → changelog.md
   - Separate changelog.md files per project (append-only paper trail)
   - Document health checks with size warnings
   - Clear categorization rules (Category A/B/C)
   - Anti-patterns to avoid (no journey narratives in main docs)

**Why:**
- Original homelab.md exceeded Claude's read limit (25K tokens)
- Documentation was mixing "current state" with "journey/history"
- No systematic approach to prevent bloat
- User kept forgetting to run /sum

**New documentation pattern:**
```
project/
├── CLAUDE.md           # Current state ONLY (200-400 lines)
├── docs/
│   ├── changelog.md    # Append-only history (paper trail)
│   └── [topic].md      # Detailed reference docs
```

**Files modified:**
- `docs/homelab.md` - Complete rewrite (lean version)
- `docs/homelab/*.md` - 6 new detailed reference files
- `commands/log.md` - Complete rewrite with smart routing
- `docs/changelog.md` - This entry

---

## 2026-01-07 - Windows PC SSH Access Setup and Documentation Update

**What changed:**
- Added documentation for accessing Windows PC via SSH through Twingate
- Updated `ssh` configuration to support Windows PC access via Twingate
- Introduced automated startup script (`/etc/wsl-ssh-startup.sh`) for WSL SSH server
- Updated `known_marketplaces.json` with new timestamp

**Why:**
- To enable secure remote access to Windows PC via SSH through Twingate
- To automate WSL SSH server startup and port forwarding on boot
- To maintain accurate documentation of remote access setup

**Files modified:**
- `docs/ssh.md` - Added Windows PC SSH access instructions and configuration
- `docs/changelog.md` - Updated with new entry for Windows PC SSH setup
- `docs/known_issues.md` - Added note about WSL SSH access gotchas
- `plugins/known_marketplaces.json` - Updated lastUpdated timestamp
- `image-cache/...` - Removed image cache files (likely temporary or obsolete)

---


## 2026-01-07 - Updated marketplace timestamp and cleaned image cache

**What changed:**
- Updated the `lastUpdated` timestamp in `plugins/known_marketplaces.json` to reflect the latest update time
- Removed an image file from the cache directory (`image-cache/c7218a46-43c8-484e-9d4d-8c7ab055a52e/1.png`)

**Why:**
- The timestamp update ensures that the marketplace plugin's last update time is correctly recorded
- The image file deletion indicates cleanup or migration of cached assets, likely related to a refresh or update in the image handling system

**Files modified:**
- `plugins/known_marketplaces.json` - Updated the `lastUpdated` field to reflect the current timestamp
- `image-cache/c7218a46-43c8-484e-9d4d-8c7ab055a52e/1.png` - File was removed from the cache

---


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ```changelog
## 2026-01-06 - Updated documentation structure and routing rules

**What changed:**
- Restructured global documentation directory layout
- Updated CLAUDE.md with new directory structure and command definitions
- Added SMART DOCUMENTATION ROUTING guidelines
- Updated slash command definitions and usage patterns
- Improved tmux session usage instructions
- Enhanced persistent session management for system-changing operations

**Why:**
- Standardized documentation structure for better maintainability
- Clarified when and where changes should be documented
- Improved consistency across all projects using the CLAUDE.md pattern
- Enhanced transparency for system-changing operations via tmux sessions
- Streamlined global command definitions and usage

**Files modified:**
- `~/.claude/CLAUDE.md` - Updated with new structure and routing rules
- `~/.claude/commands/init.md` - Updated with lean structure pattern
- `~/.claude/commands/log.md` - Updated with new documentation routing
- `~/.claude/commands/sum.md` - Updated with new archive patterns
- `~/.claude/docs/homelab/` - Updated with new homelab documentation structure
- `~/.claude/docs/` - Added new documentation categories and files

---


## December 20, 2025 - Phone Terminal Setup (oh-my-zsh + powerlevel10k)

**Summary:**
Configured phone (Samsung S25 Ultra / Termux) terminal to match Mac's oh-my-zsh + powerlevel10k setup.

**Changes Made (on phone via SSH from Mac):**

Packages Installed:
- `zsh` (5.9) - Modern shell
- `zoxide` - Already installed, smart directory navigation
- `fzf` - Already installed, fuzzy finder

Software Configured:
- **oh-my-zsh** - Cloned to `~/.oh-my-zsh`
- **powerlevel10k** - Theme cloned to `~/.oh-my-zsh/custom/themes/powerlevel10k`
- **~/.zshrc** - New config with powerlevel10k theme and Termux-compatible plugins
- **~/.p10k.zsh** - Copied from Mac for identical prompt styling
- **Default shell** - Changed to zsh via `chsh -s zsh`

Plugins Enabled:
- git, zoxide, fzf, docker, npm, python, colored-man-pages, jsontools, history, sudo

Aliases Configured:
- `vim`/`vi` → nvim
- `vz` → edit .zshrc
- `sz` → source .zshrc

**Files on Phone:**
- `~/.zshrc` - New zsh configuration
- `~/.p10k.zsh` - Copied from Mac (~/projects/zshConfig/p10k.zsh)
- `~/.oh-my-zsh/` - oh-my-zsh installation
- `~/.oh-my-zsh/custom/themes/powerlevel10k/` - Theme
- `~/.termux/shell` - Symlink to `/data/data/com.termux/files/usr/bin/zsh`

**Impact:**
- Phone terminal now matches Mac's prompt appearance
- Consistent experience across devices
- zoxide provides smart `z` navigation on phone
- Git integration in prompt shows repo status

---

## December 20, 2025 - Unified SSH Access to Mac from All Machines

**Summary:**
Set up reliable SSH access to Mac (192.168.2.226) from all homelab machines, replacing the previous `host.docker.internal` Twingate-based approach with direct LAN access.

**Changes Made:**

Mac Configuration:
- Added SSH public keys to `~/.ssh/authorized_keys` for:
  - `root@prox-tower` (ssh-rsa)
  - `jaded@ubuntu-server` (ssh-ed25519, newly generated)
  - `termux@s25ultra` (ssh-ed25519)

Remote Machine SSH Configs Updated:
- **book5** (`~/.ssh/config`) - Mac entry: `192.168.2.226`, user `j`
- **tower** (`~/.ssh/config`) - Cleaned duplicate entries, Mac entry: `192.168.2.226`, user `j`
- **termux** (`~/.ssh/config`) - Mac entry with `ProxyJump tower-fast` for cross-network access

Key Generation:
- Generated new ed25519 SSH key on ubuntu-server (didn't have one)

**Network Architecture:**
- Mac at 192.168.2.226 (management network)
- Direct access from book5, tower (same 192.168.2.x subnet)
- Termux (phone) on 192.168.1.x requires ProxyJump through tower-fast (192.168.1.249)

**Working SSH Access:**
| Source | Method | Status |
|--------|--------|--------|
| book5 | Direct | ✅ |
| tower | Direct | ✅ |
| termux | ProxyJump via tower-fast | ✅ |
| ubuntu-server | Not needed (VM) | Skipped |
| omarchy | Not needed (VM) | Skipped |

**Impact:**
- Consistent `ssh mac` command works from all homelab machines
- No longer dependent on Twingate `host.docker.internal` for local access
- Phone can SSH to Mac even when on different subnet (via ProxyJump)

**Files Modified:**
- `~/.ssh/authorized_keys` (Mac) - Added 3 new public keys
- `~/.ssh/config` (book5) - Updated Mac entry
- `~/.ssh/config` (tower) - Cleaned up, updated Mac entry
- `~/.ssh/config` (termux) - Added Mac with ProxyJump
- `~/.claude/docs/ssh-access-cheatsheet.md` - Updated Mac access documentation

**Note:** omarchy VM was unreachable at session start (encrypted disk needed login after reboot). SSH from VMs to Mac deemed unnecessary since user can ProxyJump through parent Proxmox hosts.

---

## December 20, 2025 - Mac Power Management & Documentation Split

**Changes:**
- Created `docs/mac.md` for Mac-specific configuration documentation
- Configured always-on power management to fix Twingate disconnect issues
- Separated Mac configs from homelab.md for cleaner organization

**Power Settings Applied:**
```bash
sudo pmset -a sleep 0           # System never sleeps
sudo pmset -a disablesleep 1    # Including lid close
sudo pmset -a displaysleep 10   # Display sleeps after 10 min
sudo pmset -a lowpowermode 0    # Low Power Mode off
```

**Problem Solved:**
- Mac was sleeping after 1 minute on battery (6,466+ sleep/wake cycles)
- Each sleep caused Twingate disconnect/reconnect emails
- Now Mac stays awake 24/7, display sleeps after 10 min

**Files created:**
- `docs/mac.md` - New Mac-specific configuration docs

**Files modified:**
- `CLAUDE.md` - Added mac.md to docs listing

---

## December 17, 2025 - Removed Unused Plugins (greptile, context7)

**Changes:**
- Uninstalled `greptile@claude-plugins-official` plugin
- Uninstalled `context7@claude-plugins-official` plugin
- Removed both plugins from enabledPlugins in settings.json

**Impact:**
- Reduced plugin overhead by removing unused extensions
- Remaining plugins: ralph-wiggum, commit-commands, plugin-dev

**Files modified:**
- `plugins/installed_plugins.json` - Removed greptile and context7 entries
- `settings.json` - Removed greptile and context7 from enabledPlugins

---

## December 17, 2025 - Plugin Marketplace Refresh & Cleanup

**Changes:**
- Plugin marketplace timestamp automatically updated during routine refresh
- Removed unused `logs/log-command-metrics.csv` (empty file with only header row)

**Impact:**
- No functional changes; standard metadata update and cleanup

**Files modified:**
- `plugins/known_marketplaces.json` - lastUpdated timestamp refreshed

**Files deleted:**
- `logs/log-command-metrics.csv` - Unused metrics template removed

---

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

---

## 2026-01-06 - Fixed NFS Export for ZFS Child Datasets + Plex Media Path Update

**What changed:**
- Added `crossmnt` option to NFS export on prox-tower (`/etc/exports`)
- Remounted NFS on VM 101 to pick up changes
- Updated Plex docker-compose to use new mount path `/mnt/media-pool:/media/tower`
- Recreated Plex container with new volume mapping

**Why:**
- User moved Plex media from prox-book5 (`/srv/media/`) to prox-tower's new 4TB HDD (`/media-pool/media/`)
- ZFS child datasets (`media-pool/media/Movies`, `media-pool/media/Serials`) weren't visible via NFS
- Root cause: NFS exports of parent ZFS dataset don't automatically include child datasets
- `crossmnt` option tells NFS to traverse child filesystem mount points

**Files modified:**
- prox-tower `/etc/exports` - Added `crossmnt` to media-pool export
- VM 101 `~/docker/docker-compose.yml` - Changed `/mnt/book5-media:/media/book5` → `/mnt/media-pool:/media/tower`

**Technical notes:**
- ZFS creates separate mount points for child datasets (unlike traditional directories)
- Without `crossmnt`, NFS clients see empty directories where child datasets mount
- New Plex library paths: `/media/tower/Movies/`, `/media/tower/Serials/`
- User still needs to update Plex library paths in web UI

