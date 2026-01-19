# Global Claude Code Documentation System

This directory (`~/.claude/`) contains global configuration and commands for Claude Code across all projects.

**📚 Detailed Documentation**: See `docs/` directory:
- **[projects.md](docs/projects.md)** - All active projects
- **[homelab.md](docs/homelab.md)** - Home lab server (Proxmox cluster)
- **[machine-context.md](docs/machine-context.md)** - Multi-machine documentation patterns
- **[interconnections.md](docs/interconnections.md)** - System dependency map
- **[ssh-access-cheatsheet.md](docs/ssh-access-cheatsheet.md)** - SSH quick reference
- **[troubleshooting.md](docs/troubleshooting.md)** - Common issues
- **[best-practices.md](docs/best-practices.md)** - Documentation guidelines
- **[setup.md](docs/setup.md)** - Manual project setup
- **[changelog.md](docs/changelog.md)** - Version history

---

## User Preferences

**Autonomous Workflow Execution**: When invoking documented workflows (`/init`, `/sum`, `/log`), execute the COMPLETE workflow autonomously:
- ✅ Execute ALL steps without asking permission
- ✅ Create files, symlinks, git repos, push to GitHub
- ❌ DON'T ask "Should I create X?" - just do it
- **Exception**: Only ask for genuinely ambiguous technical decisions

**Email Testing Policy**: Test emails go ONLY to `joshua@elevatedtrading.com` - never stakeholders/clients.

**File Path References**: "my Vault" or "the Vault" = `/Users/joshuabrown/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault/`

**Shell**: All systems use **zsh** (not bash). Always modify `~/.zshrc`, not `~/.bashrc`.

**Git Branch**: Always use `master` (not `main`) for new repositories. All user repos use `master`.

---

## Claude Code Limitations

**Sudo**: Passwordless sudo is enabled on all machines, but **always ask before running sudo commands**.

Example: "I need to run `sudo pmset -b lowpowermode 1` to enable Low Power Mode. Should I proceed?"

Only run sudo without asking if user explicitly requests it ("run sudo X", "do X with sudo").

**Multi-machine context**: Check `uname -s && hostname` before documenting. See [machine-context.md](docs/machine-context.md) for details.

**Distributed Documentation**: Mac is the source of truth for homelab docs. Other machines have read-only CLAUDE.md files that:
- Point to GitHub for latest docs (raw URLs)
- Use `~/notes/` for local session notes
- Mac Claude integrates notes during `/log` runs

---

## Transparency: tmux Session

Use persistent `claude` tmux session for system-changing operations:
```bash
tmux has-session -t claude 2>/dev/null || tmux new-session -d -s claude
tmux send-keys -t claude "command" Enter
```

User can watch: `tmux attach -t claude` or `tClaude` alias.

---

## Directory Structure

```
~/.claude/
├── CLAUDE.md           # This file (source of truth)
├── GEMINI.md           # Symlink → CLAUDE.md
├── AGENTS.md           # Symlink → CLAUDE.md
├── commands/           # Slash commands
│   ├── init.md         # Initialize project docs
│   ├── log.md          # Document session changes
│   └── sum.md          # Archive/compact docs
├── docs/               # Detailed documentation
│   ├── homelab/        # Homelab detailed docs
│   └── *.md            # Various topics
├── skills/             # Reusable skills
└── settings.json       # Claude Code settings
```

---

## Slash Commands

### `/init` - Initialize Project
**Fully autonomous**: Creates CLAUDE.md, symlinks, git repo, GitHub remote, adds to backup system.

### `/log` - Document Session (Smart Routing)
Documents Claude's changes with intelligent routing:
- **docs/changelog.md** - Always updated (paper trail)
- **CLAUDE.md** - Only for current-state changes (keeps it lean)
- **projects.md** - Summary update

### `/sum` - Summarize & Archive
Archives old changelog entries, compacts documentation. Run when docs exceed 500 lines.

---

## Active Projects

See **[docs/projects.md](docs/projects.md)** for details.

| Project | Purpose |
|---------|---------|
| promptLibrary | AI prompt engineering library |
| nvimConfig | Neovim config (→ `~/.config/nvim`) |
| zshConfig | ZSH config (→ `~/.zshrc`) |
| odooReports | Business automation |
| scripts | Backup system, automation |
| Elevated Vault | Obsidian knowledge base |
| n8nDev/n8nProd | n8n workflow automation |
| graveyard | Obsolete file archive |
| Home Lab | Proxmox cluster (192.168.2.250) |
| loom | Loom → SOP pipeline |

All projects have hourly automated backups to GitHub.

---

## Home Lab Quick Reference

**Full docs**: [docs/homelab.md](docs/homelab.md)

| Resource | Access |
|----------|--------|
| SSH (prox-book5) | `ssh book5` |
| SSH (prox-tower) | `ssh tower` |
| SSH (VM 101) | `ssh ubuntu` |
| SSH (Pixelbook Go) | `ssh go` / `ssh go-local` |
| SSH (Windows PC) | `ssh pc` / `ssh pc-local` |
| SSH (WSL Ubuntu) | `ssh wsl` / `ssh wsl-local` |
| SSH (Phone/Termux) | `ssh phone` / `ssh phone-local` |
| SSH (Mac) | `ssh mac` / `ssh mac-local` |
| SSH (Pi1 @ Elevated) | `ssh pi1` (via pc) |
| Samba | `smb://192.168.2.250/Shared` |
| Twingate | jaded423 network |

**Unified SSH pattern:** `ssh device` = tunnel (works anywhere), `ssh device-local` = direct (same network only). All tunnels go through book5.

**Services on VM 101**: Plex (32400), Jellyfin (8096), Ollama (11434), Frigate (5000), qBittorrent (8080)

**Roaming Devices** (Mac, Go, Phone, PC): All maintain reverse SSH tunnels to book5 for cross-device access from any network. Persistence via LaunchAgent (Mac), systemd (Go), Termux:Boot (Phone), Scheduled Task (PC).

**Pi1 @ Elevated**: Git backup mirror (15 repos, 4-hourly sync) - requires PC to be on

---

## System Interconnections

**⚠️ Before moving files**: Check [docs/interconnections.md](docs/interconnections.md)

**Critical dependencies**:
- **Symlinks**: `~/.config/nvim`, `~/.zshrc`, `~/.p10k.zsh`
- **LaunchAgents**: 3 background jobs (backup, email, claude auto)
- **Crontab**: Odoo reports, claude auto reset
- **Gmail OAuth**: Credentials in `~/projects/odooReports/AR_AP/`

---

## Graveyard

**Location**: `~/projects/graveyard/` | **Retention**: 6 months

Move obsolete files here instead of deleting. See [docs/graveyard.md](docs/graveyard.md).

---

## Multi-AI Documentation

Every project uses symlinks: **CLAUDE.md** (source) ← GEMINI.md, AGENTS.md

Edit CLAUDE.md only - symlinks auto-sync. See [docs/multi-ai-system.md](docs/multi-ai-system.md).

---

## Quick Troubleshooting

**Full guide**: [docs/troubleshooting.md](docs/troubleshooting.md)

```bash
# Commands not found?
ls ~/.claude/commands/

# Symlinks broken?
readlink GEMINI.md  # Should show: CLAUDE.md

# Automation issues?
launchctl list | grep user
crontab -l
```

---

## Resources

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [docs/projects.md](docs/projects.md) - Project details
- [docs/interconnections.md](docs/interconnections.md) - Dependency map
- [docs/troubleshooting.md](docs/troubleshooting.md) - Issues & fixes
- [docs/changelog.md](docs/changelog.md) - Version history
