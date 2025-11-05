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

**Key Features**:
- AR/AP Report: Accounts Receivable/Payable aging (PDF + Excel)
- Labels Report: Stock inventory tracking (Excel)
- Gmail OAuth integration for email delivery
- **Automated execution**: Daily at 9:00 AM weekdays via cron

**Critical Dependencies**:
- Python 3.13
- OAuth credentials in AR_AP/ directory (shared with backup system)
- Odoo API key in crontab
- Google Drive sync for report output

**Documentation**: See `~/projects/odooReports/CLAUDE.md`

## scripts
**Type**: Automation scripts collection
**Status**: Critical automation infrastructure
**Location**: `~/projects/scripts`
**Symlinked to**: `~/scripts`
**Purpose**: Centralized automation scripts for backups and notifications

**Key Features**:
- Dotfiles backup system (backs up 5 repos hourly)
- Gmail OAuth email sender (shared credentials with odooReports)
- Email reminder system (AppleScript + Python)
- **Automated backup**: Self-backed-up hourly via launchd

**Critical Scripts**:
- `dotfiles_backup.sh` - Hourly backup of 5 git repositories
- `send_gmail_oauth.py` - Reusable Gmail API email sender
- `email-reminder.scpt` - AppleScript for Gmail notifications
- `gmail-reminder.py` - Python script for Gmail API queries

**Documentation**: See `~/projects/scripts/CLAUDE.md`

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
