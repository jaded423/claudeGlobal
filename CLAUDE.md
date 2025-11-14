# Global Claude Code Documentation System

This file documents the global Claude Code configuration and slash commands available across **all projects**.

## Overview

This directory (`~/.claude/`) contains global configuration and commands that work with Claude Code across any project you're working on - whether it's Python, SQL, JavaScript, Neovim configs, or any other codebase.

**📚 Detailed Documentation**: For comprehensive information, see the `~/.claude/docs/` directory:
- **[projects.md](docs/projects.md)** - Detailed descriptions of all active projects
- **[homelab.md](docs/homelab.md)** - Home lab server documentation (cachyos-jade @ 192.168.1.228)
- **[interconnections.md](docs/interconnections.md)** - System dependency map and file movement checklists
- **[troubleshooting.md](docs/troubleshooting.md)** - Solutions for common issues
- **[best-practices.md](docs/best-practices.md)** - Documentation and workflow best practices
- **[multi-ai-system.md](docs/multi-ai-system.md)** - Multi-AI documentation with symlinks
- **[setup.md](docs/setup.md)** - Manual project setup guide
- **[graveyard.md](docs/graveyard.md)** - Obsolete file archive system
- **[changelog.md](docs/changelog.md)** - Complete version history

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
6. Add repo to automated backup system in `~/scripts/gitBackup.sh`
7. Inform user that hourly backups are now active for this repo

**Exception**: Only ask questions for genuinely ambiguous technical decisions (e.g., "Which authentication method?" when multiple valid approaches exist).

## Machine Context Detection

**ALWAYS check which machine you're operating on before documenting changes.** This system spans two machines with different documentation patterns.

### Detecting Current Machine

**Check the environment:**
```bash
# OS detection
uname -s          # Darwin = Mac, Linux = Home Lab

# Hostname detection
hostname          # Shows which specific machine

# Working directory
pwd               # Shows if you're in a Mac or Linux path structure
```

**Your Machines:**

| Machine | OS | Hostname | Home Dir | Purpose |
|---------|-----|----------|----------|---------|
| **Work Mac** | Darwin (macOS) | joshuabrown-macbook (or similar) | `/Users/joshuabrown` | Primary development, work projects |
| **Home Lab** | Linux (CachyOS) | cachyos-jade | `/home/jaded` | Server, file sharing, remote access |

### Documentation Patterns by Machine

**When working directly on Work Mac:**
- Document in relevant project's CLAUDE.md
- Global changes: Update `~/.claude/CLAUDE.md` or `~/.claude/docs/*.md`
- Changes sync to home lab automatically (hourly)

**When working directly on Home Lab (SSH session where Claude Code is running ON the server):**
- Document in `~/docs/*.md` for server-specific changes
- Global changes: Update `~/.claude/CLAUDE.md` (same global docs)
- Changes sync to work Mac automatically (hourly)

**When working from Mac via SSH to server (Claude Code running ON MAC, executing commands ON SERVER):**
- **This is the tricky case!**
- Claude Code is running on your MAC
- Commands executed via `ssh jaded@192.168.1.228 "command"` run ON SERVER
- Documentation updates happen on your MAC (where Claude Code runs)
- **Pattern:**
  - Document **what** changed on the server
  - Document **where** it changed: "on home lab server (cachyos-jade)"
  - Update home lab docs: Use SSH to edit server files OR wait for next sync
  - Update global docs on Mac: `~/.claude/docs/homelab.md` with changes

### SSH Operations from Mac: Documentation Flow

**Example:** You're on your Mac, using Claude Code to configure something on the home lab server via SSH.

**What happens:**
1. **Claude executes:** `ssh jaded@192.168.1.228 "systemctl restart sshd"`
2. **Change occurs:** On home lab server
3. **Documentation occurs:** On your Mac (where Claude Code runs)
4. **Where to document:**
   - **Global context:** Update `~/.claude/docs/homelab.md` on Mac
   - **Server-specific:** Use SSH to update `~/docs/*.md` on server OR note it in homelab.md
   - **Project-specific:** If related to a project, update that project's CLAUDE.md on Mac

**Commands to update server docs from Mac:**
```bash
# Option 1: Edit file remotely via SSH
ssh jaded@192.168.1.228 "echo 'New entry' >> ~/docs/maintenance.md"

# Option 2: Copy updated file from Mac to server
scp /tmp/updated-doc.md jaded@192.168.1.228:~/docs/

# Option 3: Let it sync naturally (if you updated ~/.claude/docs/homelab.md)
# - Mac pushes to GitHub (hourly)
# - Server pulls from GitHub (hourly)
# - Changes appear on server within ~1 hour
```

### Quick Machine Detection in Practice

**At the start of any documentation task, determine context:**

```bash
# Run this to check where you are
uname -s && hostname && pwd
```

**Then document accordingly:**
- **Darwin + Mac hostname + /Users/joshuabrown:** You're on Mac, use Mac documentation patterns
- **Linux + cachyos-jade + /home/jaded:** You're on home lab, use server documentation patterns
- **Running SSH commands from Mac:** Note that changes are on server, document in homelab.md

### Documentation Decision Tree

**Q: Where am I running Claude Code?**
- Mac → Continue
- Linux (home lab) → Document in server's `~/docs/` and `~/.claude/` (global)

**Q: Am I making changes via SSH from Mac to server?**
- No → Document on current machine normally
- Yes → Document on Mac, note changes are "on home lab server", update `~/.claude/docs/homelab.md`

**Q: Is this a project-specific change?**
- Yes → Update project's CLAUDE.md
- No → Update global docs or machine-specific docs

**Q: Should this sync to other machine?**
- Global context (both machines need to know) → Update `~/.claude/docs/homelab.md` or `~/.claude/docs/projects.md`
- Machine-specific only → Update local docs on that machine

### Examples

**Example 1: Installing package on Mac**
- Machine: Work Mac
- Action: `brew install something`
- Document: Project CLAUDE.md or global docs on Mac
- Sync: Not needed (Mac-specific)

**Example 2: Configuring Samba on home lab while SSH'd from Mac**
- Machine: Work Mac (running Claude Code)
- Target: Home lab server (via SSH)
- Action: `ssh jaded@192.168.1.228 "sudo systemctl restart smb"`
- Document: `~/.claude/docs/homelab.md` on Mac with note "Updated Samba configuration on cachyos-jade server"
- Optionally: SSH to update `~/docs/maintenance.md` on server for detailed local docs
- Sync: Automatic (homelab.md syncs to server hourly)

**Example 3: Updating Hyprland config while logged into home lab**
- Machine: Home lab (SSH session, Claude Code running on server)
- Action: Edit `~/.config/hypr/hyprland.conf`
- Document: `~/docs/desktop-environment.md` on server
- Sync: Not critical (desktop config is local to server)

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

**Lean CLAUDE.md Structure for `/init`**: When creating project documentation with `/init`, **ALWAYS use the lean structure pattern**:

**Main CLAUDE.md (100-150 lines)**:
- Overview and purpose (2-3 paragraphs)
- Directory structure with brief descriptions
- Quick reference section with essential commands
- Links to detailed documentation: `**📚 Detailed Documentation**: See the docs/ directory:`
- Version requirements and dependencies
- Reference to full changelog: `**Full changelog**: [docs/changelog.md](docs/changelog.md)`

**docs/ subdirectory** with specialized files:
- **docs/architecture.md** - Technical architecture, design patterns, system components
- **docs/workflows.md** - Development workflows, common tasks, how-tos
- **docs/commands.md** - Comprehensive command reference (if project has many commands)
- **docs/troubleshooting.md** - Common issues and solutions
- **docs/changelog.md** - Complete version history (ready for `/sum` command)

**Pattern example**:
```markdown
# Project Name Documentation

## Overview
Brief description of what this project is and does.

**📚 Detailed Documentation**: See the `docs/` directory:
- **[architecture.md](docs/architecture.md)** - Technical design
- **[workflows.md](docs/workflows.md)** - Development workflows
- **[changelog.md](docs/changelog.md)** - Version history

## Quick Start
Essential commands and quick reference...

## Version History
**Full changelog**: [docs/changelog.md](docs/changelog.md)
```

**Benefits**:
- Main file stays manageable (<150 lines)
- Detailed content organized by topic
- Easier to maintain and navigate
- Compatible with `/sum` command for archiving
- Follows same pattern as global `~/.claude/` docs

**All existing projects already use this pattern**: promptLibrary, nvimConfig, odooReports, scripts, zshConfig, graveyard, n8nDev, n8nProd.

**File Path References**: When the user references **"my Vault"** or **"the Vault"**, they mean:

```
/Users/joshuabrown/Library/CloudStorage/GoogleDrive-joshua@elevatedtrading.com/My Drive/Elevated Vault/
```

This is the Obsidian knowledge base stored in Google Drive. No need to search for it - use this path directly.

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
│   ├── homelab.md      # Home lab server documentation
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
7. Adds repo to `~/scripts/gitBackup.sh` REPOS array
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
3. **zshConfig** - ZSH shell config (symlinked to `~/.zshrc`)
4. **odooReports** - Business automation for Elevated Trading
5. **scripts** - Automation infrastructure (backup system, email)
6. **Elevated Vault** - Obsidian knowledge base in Google Drive
7. **n8nDev** - n8n development environment (Docker, port 5678)
8. **n8nProd** - n8n production environment (Docker, port 5679)
9. **graveyard** - Obsolete file archive (6-month retention)
10. **Home Lab** - CachyOS Linux server (192.168.1.228) with SSH, Samba, Twingate, Ollama

All projects have hourly automated backups to GitHub.

## Home Lab - cachyos-jade

**Full documentation**: **[docs/homelab.md](docs/homelab.md)**

**Quick access**:
- SSH: `ssh jaded@192.168.1.228`
- Samba: `smb://192.168.1.228/Shared`
- Services: Twingate, Docker, Ollama, Hyprland, Google Drive (rclone)

**Key services**: SSH server, Samba file sharing, Twingate secure remote access, Docker, Ollama local LLMs (7 models, GPU-accelerated), Hyprland desktop (Osaka-Jade theme), Google Drive integration (2 accounts).

## Graveyard - Obsolete File Archive

**Location**: `~/projects/graveyard/` | **Retention**: 6 months | **Full docs**: [docs/graveyard.md](docs/graveyard.md)

Safety net for file deletion. Move obsolete files here instead of deleting immediately - provides 6-month retention for "just in case" scenarios.

**Quick usage**: `mv old_file.py ~/projects/graveyard/projectName/` then log in graveyard/CLAUDE.md

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

**Full docs**: [docs/multi-ai-system.md](docs/multi-ai-system.md)

Every project uses symlinks for multi-AI support: **CLAUDE.md** (source), **GEMINI.md** → CLAUDE.md, **AGENTS.md** → CLAUDE.md. Edit CLAUDE.md only - symlinks auto-sync. Use `/sum` when docs exceed 500 lines.

## Setting Up a New Project

**Recommended**: Use `/init` command - fully automated (docs, git, GitHub, backups).

**Manual setup**: See [docs/setup.md](docs/setup.md) for step-by-step guide.

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

**Full guide**: [docs/best-practices.md](docs/best-practices.md)

**Quick tips**: Be specific in changelogs (file paths + why), commit code + docs together, use `/log` at end of sessions, run `/sum` monthly when docs exceed 500 lines.

## Version History

**Full changelog**: [docs/changelog.md](docs/changelog.md)

**Recent updates**:
- **Nov 6, 2025** - Removed auto-commit from `/log` command, added graveyard system
- **Nov 5, 2025** - Moved global config to version control with automated backups
- **Nov 4, 2025** - Documentation restructure for efficiency (1100+ → ~300 lines)
- **Nov 3, 2025** - Switched to symlinks for multi-AI documentation

## Resources

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [Slash Commands Guide](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Project Documentation](https://docs.claude.com/en/docs/claude-code/project-docs)
- **[Detailed Project Info](docs/projects.md)** - All active projects
- **[System Interconnections](docs/interconnections.md)** - Dependency map
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common issues
