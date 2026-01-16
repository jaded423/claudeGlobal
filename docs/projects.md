# Active Projects Overview

Detailed descriptions of all active projects in your workspace.

## prompts
**Type**: AI prompt collection
**Status**: Active
**Last Updated**: 2026-01-07
**Recent Changes**: Created project with 1-3-1 Problem Solving Coach prompt (refined from Gemini gem)
**Location**: `~/projects/prompts`
**Purpose**: Refined AI prompts for use with Claude, Gemini, and local LLMs

**Current Prompts**:
- `1-3-1claude.md` - Dan Martell's 1-3-1 problem-solving framework coach

**Key Features**:
- Production-ready prompts tested across multiple AI platforms
- Companion SOPs in `~/projects/loom/SOPs/` with walkthroughs and test scenarios
- Versioned refinements with documented improvements

**Documentation**: See `~/projects/prompts/CLAUDE.md`

## promptLibrary
**Type**: Documentation
**Status**: Active reference library
**Location**: `~/projects/promptLibrary`
**Purpose**: Curated AI prompt engineering library with empirical testing and versioning

**Key Features**:
- Versioned prompts (v1.0, v2.0, etc.)
- Effectiveness ratings (⭐ 1-5)
- Testing log with success metrics
- Model-specific optimization (Claude vs GPT-4)
- Frameworks: prompt-design-framework, advanced-techniques, debugging-playbook

**Documentation**: See `~/projects/promptLibrary/CLAUDE.md`

## nvimConfig
**Type**: Neovim configuration (Lua)
**Status**: Active daily driver
**Location**: `~/projects/nvimConfig`
**Symlinked to**: `~/.config/nvim`
**Also on**: Windows PC (WSL) - synced 2026-01-07
**Purpose**: Modern, feature-rich Neovim setup

**Key Features**:
- Plugin manager: lazy.nvim
- LSP + Mason + Tree-sitter
- Debugging: nvim-dap
- Testing: neotest
- AI assistance: GitHub Copilot
- **Automated backup**: Hourly via launchd

**PC Notes**: nvim 0.11.5 (AppImage), deno for peek.nvim, fd/rg for telescope, ascii-image-converter for dashboard

**Documentation**: See `~/projects/nvimConfig/CLAUDE.md`

## zshConfig
**Type**: ZSH configuration
**Status**: Active shell config
**Last Updated**: 2026-01-09
**Recent Changes**: Deployed to Pi1 (Raspberry Pi 1 B+) with Linux adaptations, doom-ascii installed
**Location**: `~/projects/zshConfig`
**Symlinked to**: `~/.zshrc`, `~/.p10k.zsh`, `~/.zsh/functions/`
**Also on**: Windows PC (WSL), Pi1 @ Elevated
**Purpose**: Shell configuration with split-file security model

**Key Features**:
- Oh My Zsh + Powerlevel10k theme
- Secrets in `~/.zshrc.local` (local only, not committed)
- **Modular functions**: 7 files in `functions/` directory
  - `claude.zsh` - Auto-update wrapper for Claude Code
  - `git-functions.zsh` - `gitall`, `gitrepos`, `commits` (cross-repo commit history)
  - `backup-functions.zsh` - `gitvi`, `gitdot` backup functions
  - `doc-functions.zsh` - `doc-check`, `doc-metrics`
  - `fzf.zsh` - FZF config with previews (`Ctrl+F` dir nav, `Ctrl+T` files, `Ctrl+R` history)
  - `ssh-functions.zsh` - SSH machine shortcuts, `OOO` travel safety function
  - `utils.zsh` - `docxdiff` for Office file comparison
- **Automated backup**: Hourly via launchd

**Security Model**:
- Main `.zshrc` contains NO secrets (safe to commit)
- `.zshrc.local` contains API keys and sensitive data (gitignored)
- `.zshrc` automatically sources `.zshrc.local` if it exists

**Documentation**: See `~/projects/zshConfig/CLAUDE.md`

## odooReports
**Type**: Python automation system
**Status**: Active business automation
**Location**: `~/projects/odooReports` (Mac source), `/home/joshua/projects/odooReports/` (WSL execution)
**Purpose**: Automated reporting for Elevated Trading
**Last Updated**: 2026-01-12
**Recent Changes**: Migrated cron jobs from Mac to PC/WSL for reliable 24/7 execution. Mac was sleeping at 6 AM causing missed Monday reports.

**Reports**:
- **AR/AP Report**: Accounts Receivable/Payable aging (PDF + Excel) - daily 9 AM weekdays
- **Labels Report**: Stock inventory tracking (Excel) - daily 6 AM weekdays, Monday email
- **Last Order Reports**: Customer order history (PDF + Excel) - Mondays 6 AM
  - Justin's: 16 named key accounts → joshua, cynthia, shannon
  - Brad's: All Brad Bush customers (78 paying, 21 sample) → joshua, brad
  - Joe's: All Joe Gibson customers (65 paying, 20 sample) → joshua, joe
- **Manufacturing Report**: Weekly production with profit analysis (Excel) - Mondays 6 AM
- **Buying Patterns Report**: Pounds vs partials analysis (Excel) - manual run only

**Key Features**:
- Gmail OAuth integration for email delivery
- Professional PDF reports with company branding
- Color-coded status indicators (green/yellow/red)
- **Automated execution**: Via WSL cron on always-on PC (`ssh wsl`)
- **Secure credentials**: Centralized in gitignored odoo_credentials.json file

**Critical Dependencies**:
- Python 3.12 (WSL) / Python 3.13 (Mac)
- OAuth credentials in AR_AP/ directory (shared across reports)
- Odoo credentials in `odoo_credentials.json` (gitignored)

**Documentation**: See `~/projects/odooReports/CLAUDE.md`

## odooModules
**Type**: Odoo 17 module development
**Status**: Active development
**Last Updated**: 2026-01-06
**Recent Changes**: Built DB Explorer module (Phase 1 & 2) - Model Browser, SQL Query Runner, saved queries, CSV export
**Location**: `~/projects/odooModules`
**Server**: VM 101 (Ubuntu) @ 192.168.2.126, Odoo on port 8069
**Purpose**: Custom Odoo module development for self-hosted instance

**Key Features**:
- DB Explorer module - browse models, fields, run SQL queries
- Server aliases: `odooUp` (restart Odoo), `odooLogs` (view logs)
- Development reference docs for Odoo 17

**Current Modules**:
- `db_explorer` - Database exploration and SQL query tool (Phase 1 & 2 complete)
- `library_app` - First learning module (books)

**Installed OCA Modules**:
- mis_builder, account_financial_report, report_xlsx, date_range, web_responsive

**Documentation**: See `~/projects/odooModules/CLAUDE.md`

## scripts
**Last Updated:** 2026-01-16
**Recent Changes:** Updated the last_run timestamp in the photos sync state file to reflect the latest synchronization run time.

**Type**: Automation scripts collection
**Status**: Critical automation infrastructure
**Location**: `~/projects/scripts`
**Symlinked to**: `~/scripts`
**Purpose**: Centralized automation scripts for backups and notifications

**Key Features**:
- Dotfiles backup system (backs up 14 repos hourly)
- **AI commit messages** - Hybrid approach (v3.6.0):
  - Primary: code16 (qwen2.5-coder:7b with 16K context, local Ollama)
  - Fallback: Claude Sonnet API (200K context, full diff for better results)
  - Pre-loaded with 24h keepalive via systemd service
  - Smart truncation: diffs >175 lines truncated to ~150 lines of actual code
  - Sends real code changes to model, not just file names
  - Commit time: ~10s with model loaded (28x faster than phi4.16k)
- Gmail OAuth email sender (shared credentials with odooReports)
- Email reminder system (AppleScript + Python)
- **Automated backup**: Self-backed-up hourly via launchd

**Critical Scripts**:
- `gitBackup.sh` - Hourly backup of 14 git repositories
- `ollamaSummary.py` - Ollama-powered commit generator (code16)
- `send_gmail_oauth.py` - Reusable Gmail API email sender
- `email-reminder.scpt` - AppleScript for Gmail notifications
- `gmail-reminder.py` - Python script for Gmail API queries

**Documentation**: See `~/projects/scripts/CLAUDE.md`

## claudeGlobal
**Type**: Claude Code global configuration
**Status**: Active critical infrastructure
**Last Updated**: 2025-12-17
**Recent Changes**: Removed unused plugins (greptile, context7) - keeping only ralph-wiggum, commit-commands, plugin-dev
**Location**: `~/projects/.claude`
**Symlinked to**: `~/.claude`
**Purpose**: Global configuration for Claude Code across all projects

**Key Features**:
- Global slash commands: `/compact`, `/log`, `/init`
- Custom agents: gemini-researcher, orchestrator, security-auditor, ultimate-researcher
- Documentation system: CLAUDE.md (source), GEMINI.md, AGENTS.md (symlinks)
- Detailed docs: projects.md, interconnections.md, troubleshooting.md, project-logs/
- Global settings and permissions configuration
- **Automated backup**: Hourly via launchd (as of 2025-11-05)
- **Conversation history**: Now in dedicated claudeHistory repo (as of 2025-12-09)

## claudeHistory
**Type**: Claude Code conversation history
**Status**: Active critical infrastructure
**Last Updated**: 2025-12-09
**Recent Changes**: Created dedicated repository for complete conversation history sync
**Location**: `~/projects/claudeHistory`
**Symlinked from**: `~/.claude/history.jsonl` and `~/.claude/projects/`
**Purpose**: Single source of truth for Claude Code conversations across all machines

**Key Features**:
- Complete conversation history: 1,312 conversations, 757 session files (97 MB)
- Automatically syncs via `claude` command wrapper function
- Works with hourly automated backup system
- Keeps main .claude repo lean (config only)
- Multi-AI documentation (GEMINI.md, AGENTS.md symlinks)

**How It Works**:
- `~/.claude/history.jsonl` → symlink to `~/projects/claudeHistory/history.jsonl`
- `~/.claude/projects/` → symlink to `~/projects/claudeHistory/projects/`
- Typing `claude` automatically pulls latest from both .claude and claudeHistory repos
- Ensures you can access any conversation from any machine

**Documentation**: See `~/projects/claudeHistory/CLAUDE.md`

**Critical Functionality**:
- `/log` command - Autonomous documentation of Claude's session changes (no auto-commit)
- `/init` command - Full project setup (docs, git, GitHub, backups)
- `/compact` command - Archive and compress documentation
- Cross-project awareness via docs/projects.md
- Hourly backup with AI-generated commit messages via Claude Haiku
- `claudegit` alias - Syncs conversation history before launching Claude

**Version Control**:
- Repository: `github.com/jaded423/claudeGlobal` (private)
- Symlink approach: Zero disruption to Claude Code functionality
- Now tracks: `history.jsonl` for cross-machine conversation sync (1,281 conversations)
- Excludes session data: debug/, file-history/, todos/, projects/
- Tracks: documentation, commands, agents, skills, settings, conversation history

**Documentation**: See `~/projects/.claude/CLAUDE.md`

## Elevated Vault (Obsidian)
**Type**: Obsidian knowledge base
**Status**: Active knowledge management
**Location**: `~/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault`
**Purpose**: Personal knowledge base in Google Drive with PARA organization

**Key Features**:
- PARA structure (Projects, Areas, Resources, Archive)
- Complete ESV Bible in markdown
- Technical cheatsheets (tmux, neovim, git, bash, SQL)
- Business automation documentation
- Certification study plans (Google Cloud, CompTIA A+)
- **Automated backup**: Hourly via launchd

**Special Considerations**:
- Synced via Google Drive Desktop app
- Backup script uses 2-second delay + retry logic for cloud sync
- Contains sensitive business credentials in `03-areas/business/`

**Documentation**: See vault's internal `CLAUDE.md`

## n8nDev
**Type**: Workflow automation (Docker + n8n)
**Status**: Active development environment
**Location**: `~/projects/n8nDev`
**Last Updated**: 2025-11-05
**Purpose**: Development environment for building and testing n8n workflow automations

**Key Features**:
- Docker containerized n8n instance (port 5678)
- Timezone configured (America/Chicago) for scheduled workflows
- Comprehensive execution logging (keep all for debugging)
- Safe sandbox for testing before production deployment
- **Automated backup**: Hourly via launchd

**Recent Changes:** Created complete n8n development infrastructure with Docker, comprehensive documentation, GitHub integration, and hourly automated backups

**Use Cases**:
- Test workflow automations before production
- Migrate Python-based reports to visual workflows
- Primary environment for building odooReports migration

**Documentation**: See `~/projects/n8nDev/CLAUDE.md`

## n8nProd
**Type**: Workflow automation (Docker + n8n)
**Status**: Active production environment
**Location**: `~/projects/n8nProd`
**Last Updated**: 2025-11-05
**Purpose**: Production environment for reliable, automated workflow execution

**Key Features**:
- Docker containerized n8n instance (port 5679)
- Timezone configured (America/Chicago) for scheduled workflows
- 14-day execution retention with auto-pruning
- Separate from dev - can run simultaneously
- **Automated backup**: Hourly via launchd

**Recent Changes:** Created complete n8n production infrastructure with stricter data management, production-optimized settings, and deployment documentation

**Use Cases**:
- Run validated automations from n8nDev
- Replace cron-based Python scripts (odooReports)
- Business process automation (AR/AP reports, inventory tracking)

**Documentation**: See `~/projects/n8nProd/CLAUDE.md`

## Home Lab - Proxmox Cluster "home-cluster"

**Type**: Proxmox VE cluster infrastructure
**Status**: Active production cluster (2 nodes)
**Location**: 192.168.2.x network, accessible via Twingate remotely
**Last Updated**: 2026-01-10
**Recent Changes**: Added Pixelbook Go with Twingate connector in Crostini (`ssh go`); documented Claude Bridge technique for cross-machine AI collaboration
**Nodes**:
  - prox-book5 @ 192.168.2.250 (Samsung Galaxy Book5 Pro, 16GB RAM, hosts VM 100)
  - prox-tower @ 192.168.2.249 (ThinkStation 510, 78GB RAM, Xeon E5-2683 v4 16c/32t, 2.5GbE, ZFS storage, hosts VM 101 with 28 vCPUs)
**Purpose**: Clustered home lab infrastructure with HA capabilities, hosting development and production services

**Key Services**:
- **SSH Server** - Remote terminal access (port 22)
- **Samba File Server** - Cross-platform file sharing (ports 445, 139)
- **Twingate Connector** - Secure remote access via Zero Trust network
- **Docker** - Container runtime for Twingate and future services
- **Hyprland Desktop** - Wayland compositor with Osaka-Jade theme
- **Google Drive Integration** - Two rclone FUSE mounts (personal + elevated)
- **Pi-hole DNS** - Network-wide ad blocking on Raspberry Pi 1 B+ (192.168.1.191) with DNS-over-TLS support
- **Frigate NVR** - AI camera system on VM 101 (port 5000), CUDA video decode, Tapo C210 camera

**Hardware**:
- RAM: 16GB (3.6GB used, 11GB available)
- Storage: 952GB NVMe (2% used, plenty of space)
- CPU: x86_64

**Access Methods**:
- **At Home**: Direct LAN access (192.168.1.228) - 60+ MB/s transfers
- **Remote**: Twingate network (jaded423) - secure tunnel through home upload speed

**SSH Access from Work Mac**:
```bash
ssh jaded@192.168.1.228
```

**Samba Access from Work Mac**:
```bash
# Finder: Cmd+K, then:
smb://192.168.1.228/Shared
```

**Shared Directories** (via Samba):
- Music, Pictures, Documents, Videos (symlinked from /home/jaded/)

**Desktop Environment**:
- Window Manager: Hyprland (Wayland)
- Theme: Osaka-Jade (dark forest green + jade/teal accents)
- Status Bar: Waybar
- Terminals: Kitty & Alacritty (85% opacity)
- Wallpapers: 3 Osaka-Jade themed backgrounds
- Shell: fish (Oh My Fish)

**Google Drive Mounts**:
- Personal: ~/GoogleDrive/ (remote: gdrive)
- Elevated: ~/elevatedDrive/ (remote: elevated)
- VFS cache: 24-hour retention, write mode
- Auto-mount via systemd user services

**Security**:
- UFW firewall active (deny incoming by default)
- SSH: Public key auth enabled (work Mac key installed)
- Samba: User authentication required (no guest access)
- Twingate: Zero Trust - no ports exposed to internet

**Setup Documentation**:
- Server-side: ~/README.md (comprehensive setup guide)
- Setup scripts: ~/setup/ (install scripts, docker-compose, configs)
- Global docs: ~/.claude/docs/homelab.md (full documentation)

**Service Management**:
```bash
# Check all services
systemctl status sshd smb
docker ps

# Restart services
systemctl restart sshd smb
docker-compose restart

# View logs
journalctl -u sshd -f
journalctl -u smb -f
docker logs -f twingate-connector
```

**Network Configuration**:
- Twingate Network: jaded423
- Admin Console: https://jaded423.twingate.com
- Resources: SSH (assigned to jaded), File Sharing (assigned to family)

**Future Enhancements**:
- Additional Docker services (Portainer, monitoring, media server)
- Automated backups to work Mac
- CI/CD pipeline
- Development environment setup

**Documentation**: See **[~/.claude/docs/homelab.md](homelab.md)** for complete documentation

## loom
**Type**: Automation pipeline
**Status**: Active
**Last Updated**: 2025-12-22
**Recent Changes**: Added `--update` and `--transcribed` flags for post-generation editing and existing transcript support. Created man page (`man loom`).
**Location**: `~/projects/loom`
**GitHub**: Private repo with hourly backups
**Purpose**: Convert Loom training videos into professional SOPs with HTML/PDF exports

**Key Features**:
- **Fully hands-off**: One command does everything, returns to prompt when done
- Bash handles download (yt-dlp) and transcription (Whisper)
- Claude creates SOP with `--dangerously-skip-permissions` for autonomous file creation
- Background monitor detects completion and auto-exits Claude
- Uses subscription tokens (not API) - saves money
- Professional HTML/PDF exports for sharing with staff
- **Update mode**: Edit .md, regenerate HTML/PDF (`loom -u topic`)
- **Transcribed mode**: Skip download, use existing transcript (`loom -t file topic`)
- **Man page**: Full documentation via `man loom`

**Workflow**:
```bash
# Full pipeline (Loom URL)
loom https://www.loom.com/share/VIDEO_ID topic-name

# From existing transcript (skip download/transcribe)
loom -t existing-transcript.txt topic-name

# Edit markdown, regenerate outputs
loom -u topic-name
```

**Output**:
- `transcriptions/{topic}-{date}.txt` - Raw transcript
- `SOPs/{topic}.md` - Markdown SOP (source of truth for edits)
- `SOPs/{topic}.html` - Styled HTML
- `SOPs/{topic}.pdf` - Print-ready PDF

**Key Files**:
- `bin/loom` - Main pipeline script (3 modes: full, transcribed, update)
- `bin/loom-monitor` - Background completion detector
- `.claude/commands/sop.md` - SOP creation slash command
- `.claude/commands/sop-update.md` - HTML/PDF regeneration slash command
- `man/loom.1` - Unix man page

**Documentation**: See `~/projects/loom/CLAUDE.md` or `man loom`

---

## OrphanedTasks
**Type**: macOS App (Swift/SwiftUI)
**Status**: Active, functional
**Last Updated**: 2026-01-08
**Recent Changes**: Initial release - complete menu bar app with global hotkey, screenshots, reminders, settings
**Location**: `~/projects/OrphanedTasks`
**Purpose**: Capture and track interrupted tasks with automatic reminders

**Key Features**:
- Global hotkey `Cmd+Shift+O` for instant capture from any app
- Interactive screenshot selection + quick note
- Persistent reminders every N minutes until marked complete
- Configurable intervals: 5, 10, 15, 30, 45 min or 1, 2, 4 hours
- History tracking for completed tasks
- Menu bar UI (unobtrusive, always accessible)
- Swift 6 compliant (zero warnings)

**Data Location**: `~/Library/Containers/com.jaded.OrphanedTasks/Data/OrphanTasks/`

**Documentation**: See `~/projects/OrphanedTasks/CLAUDE.md`

---

## Other Projects (Not Actively Documented)

### adv360ProZmk
**Location**: `~/projects/adv360ProZmk`
**Type**: Keyboard firmware (ZMK)
**Purpose**: Kinesis Advantage 360 Pro configuration

### bibleGatewayToObsidian
**Location**: `~/projects/bibleGatewayToObsidian`
**Type**: Shell + Ruby script
**Purpose**: Fetch Bible text from BibleGateway for Obsidian

### gitCheatsheet
**Location**: `~/projects/gitCheatsheet`
**Type**: Documentation
**Purpose**: Personal Git workflow reference

### llmsFromScratch
**Location**: `~/projects/llmsFromScratch`
**Type**: Learning materials (Python)
**Purpose**: Study materials from "LLMs from Scratch" book
