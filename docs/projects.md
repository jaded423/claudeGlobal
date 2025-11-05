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

## dotfilesPrivate
**Type**: ZSH configuration
**Status**: Active shell config
**Location**: `~/projects/dotfilesPrivate`
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
**Last Updated:** 2025-11-05
**Recent Changes:** Added Claude Global config to automated backup system

**Type**: Automation scripts collection
**Status**: Critical automation infrastructure
**Location**: `~/projects/scripts`
**Symlinked to**: `~/scripts`
**Purpose**: Centralized automation scripts for backups and notifications

**Key Features**:
- Dotfiles backup system (backs up 6 repos hourly)
- Gmail OAuth email sender (shared credentials with odooReports)
- Email reminder system (AppleScript + Python)
- **Automated backup**: Self-backed-up hourly via launchd

**Critical Scripts**:
- `dotfiles_backup.sh` - Hourly backup of 6 git repositories
- `send_gmail_oauth.py` - Reusable Gmail API email sender
- `email-reminder.scpt` - AppleScript for Gmail notifications
- `gmail-reminder.py` - Python script for Gmail API queries

**Documentation**: See `~/projects/scripts/CLAUDE.md`

## claudeGlobal
**Last Updated:** 2025-11-05
**Recent Changes:** Moved to version control, created /log command, added to automated backups

**Type**: Claude Code global configuration
**Status**: Active critical infrastructure
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

**Critical Functionality**:
- `/log` command - Autonomous documentation of Claude's session changes
- `/init` command - Full project setup (docs, git, GitHub, backups)
- `/compact` command - Archive and compress documentation
- Cross-project awareness via docs/projects.md

**Version Control**:
- Repository: `github.com/jaded423/claudeGlobal` (private)
- Symlink approach: Zero disruption to Claude Code functionality
- Excludes session data: debug/, file-history/, todos/, projects/
- Tracks: documentation, commands, agents, skills, settings

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

## hello-ai
**Type**: Test project (Python)
**Status**: Test/demo project
**Location**: `~/projects/hello-ai`
**Purpose**: Validates `/init` workflow functionality

**Key Features**:
- Recursive hello world implementation
- Educational recursion example
- **Automated backup**: Hourly via launchd

**Documentation**: See `~/projects/hello-ai/CLAUDE.md`

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
