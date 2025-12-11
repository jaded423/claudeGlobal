# Active Projects Overview

Detailed descriptions of all active projects in your workspace.

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
**Purpose**: Modern, feature-rich Neovim setup

**Key Features**:
- Plugin manager: lazy.nvim
- LSP + Mason + Tree-sitter
- Debugging: nvim-dap
- Testing: neotest
- AI assistance: GitHub Copilot
- **Automated backup**: Hourly via launchd

**Documentation**: See `~/projects/nvimConfig/CLAUDE.md`

## zshConfig
**Type**: ZSH configuration
**Status**: Active shell config
**Last Updated**: 2025-12-09
**Recent Changes**: Replaced `claudegit` alias with `claude()` wrapper function - now typing `claude` automatically syncs global config and conversation history before launch
**Location**: `~/projects/zshConfig`
**Symlinked to**: `~/.zshrc`, `~/.p10k.zsh`
**Purpose**: Shell configuration with split-file security model

**Key Features**:
- Oh My Zsh + Powerlevel10k theme
- Secrets in `~/.zshrc.local` (local only, not committed)
- Custom functions: `backup-nvim()`, `backup-dotfiles()`, `check-all-repos()`
- **Automated backup**: Hourly via launchd

**Security Model**:
- Main `.zshrc` contains NO secrets (safe to commit)
- `.zshrc.local` contains API keys and sensitive data (gitignored)
- `.zshrc` automatically sources `.zshrc.local` if it exists

**Documentation**: See `~/projects/dotfilesPrivate/CLAUDE.md`

## odooReports
**Type**: Python automation system
**Status**: Active business automation
**Location**: `~/projects/odooReports`
**Purpose**: Automated daily reporting for Elevated Trading
**Last Updated**: 2025-11-05
**Recent Changes**: Refactored credentials management for improved security - removed plaintext API key from crontab, created centralized odoo_credentials.json file

**Key Features**:
- AR/AP Report: Accounts Receivable/Payable aging (PDF + Excel)
- Labels Report: Stock inventory tracking (Excel)
- Gmail OAuth integration for email delivery
- **Automated execution**: Daily at 9:00 AM weekdays via cron
- **Secure credentials**: Centralized in gitignored odoo_credentials.json file

**Critical Dependencies**:
- Python 3.13
- OAuth credentials in AR_AP/ directory (shared with backup system)
- Odoo credentials in `odoo_credentials.json` (gitignored, NOT in crontab)
- Google Drive sync for report output

**Documentation**: See `~/projects/odooReports/CLAUDE.md`

## scripts
**Last Updated:** 2025-12-11
**Recent Changes:** Removed system health checks - cleaner code, no unnecessary SSH connections when no backups occur

**Type**: Automation scripts collection
**Status**: Critical automation infrastructure
**Location**: `~/projects/scripts`
**Symlinked to**: `~/scripts`
**Purpose**: Centralized automation scripts for backups and notifications

**Key Features**:
- Dotfiles backup system (backs up 14 repos hourly)
- **AI commit messages** - Single-model approach (v3.2):
  - Model: phi4.16k (phi4:14b with 16K context, local Ollama)
  - Pre-loaded with 60m keepalive (73ms load time vs 20s cold)
  - Condensed summaries for diffs >50 lines
  - Claude History repo uses instant file-count commits (no AI)
  - Commit time: ~40s per commit (higher quality than 7B)
- Smart diff parsing for large commits
- Gmail OAuth email sender (shared credentials with odooReports)
- Email reminder system (AppleScript + Python)
- **Automated backup**: Self-backed-up hourly via launchd

**Critical Scripts**:
- `gitBackup.sh` - Hourly backup of 14 git repositories
- `ollamaSummary.py` - Ollama-powered commit generator (phi4.16k)
- `send_gmail_oauth.py` - Reusable Gmail API email sender
- `email-reminder.scpt` - AppleScript for Gmail notifications
- `gmail-reminder.py` - Python script for Gmail API queries

**Documentation**: See `~/projects/scripts/CLAUDE.md`

## claudeGlobal
**Type**: Claude Code global configuration
**Status**: Active critical infrastructure
**Last Updated**: 2025-12-09
**Recent Changes**: Separated conversation history into dedicated claudeHistory repo, main repo now config-only (removed history.jsonl from tracking)
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
**Last Updated**: 2025-12-09
**Recent Changes**: Upgraded VM 102 (ubuntu-server) resources - RAM 20GB→40GB, CPU cores 3→6, removed cpulimit, resized swap 44GB→20GB. Host now has 78GB RAM after hardware upgrade.
**Nodes**:
  - prox-book5 @ 192.168.2.250 (Samsung Galaxy Book5 Pro, 16GB RAM, hosts VM 100)
  - prox-tower @ 192.168.2.249 (ThinkStation 510, 78GB RAM, Xeon E5-1620 v4, hosts VM 102)
**Purpose**: Clustered home lab infrastructure with HA capabilities, hosting development and production services

**Key Services**:
- **SSH Server** - Remote terminal access (port 22)
- **Samba File Server** - Cross-platform file sharing (ports 445, 139)
- **Twingate Connector** - Secure remote access via Zero Trust network
- **Docker** - Container runtime for Twingate and future services
- **Hyprland Desktop** - Wayland compositor with Osaka-Jade theme
- **Google Drive Integration** - Two rclone FUSE mounts (personal + elevated)
- **Pi-hole DNS** - Network-wide ad blocking on Raspberry Pi 1 B+ (192.168.1.191) with DNS-over-TLS support

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
