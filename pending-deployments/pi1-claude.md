# Claude Code - Pi1 (Git Backup Mirror)

**Machine:** Raspberry Pi 1 Model B+
**IP:** 192.168.137.123 (ICS subnet)
**User:** pi
**OS:** Raspberry Pi OS (Legacy) Bookworm Lite
**Shell:** zsh + Oh My Zsh + Powerlevel10k

---

## Important: You Are NOT the Source of Truth

The **Mac (MacBook Air)** maintains all homelab documentation. Your role is to:
1. **Read** existing docs from GitHub when you need context
2. **Save** session notes locally for later integration
3. **Do NOT** try to maintain comprehensive docs here

---

## Reading Homelab Documentation

All homelab docs are available on GitHub. To find information about any machine or service:

```bash
# View the main homelab overview
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab.md

# View this machine's docs
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab/pi1.md

# View other machine docs (replace MACHINE with: phone, mac, ubuntu, omarchy, tower, book5, etc.)
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/homelab/MACHINE.md

# View SSH access cheatsheet
curl -s https://raw.githubusercontent.com/jaded423/scripts/master/.claude/docs/ssh-access-cheatsheet.md
```

**GitHub Repos:** https://github.com/jaded423
- `scripts` - Contains ~/.claude/docs/ (homelab documentation)

---

## Saving Session Notes

When you make changes or discoveries, save notes for Mac Claude to integrate later.

**Location:** `~/notes/`
**Format:** `YYYY-MM-DD-topic.md`

### Note Template

```markdown
# Session Notes - YYYY-MM-DD
**Machine:** pi1 (Raspberry Pi 1 - Git Backup Mirror)
**Summary:** Brief description of what was done

---

## Changes Made
- What you configured/fixed/installed
- Commands used
- Files modified

## For Integration
Items that should be added to homelab docs:
- Git mirror changes
- Sync script changes
- Network/connectivity changes

## Raw Details
Any verbose output, configs, or reference material
```

---

## This Machine's Configuration

### Hardware
- **Model:** Raspberry Pi 1 Model B+
- **CPU:** ARM1176JZF-S (700MHz single-core)
- **RAM:** 512MB

### Network
- **IP:** 192.168.137.123 (static on ICS subnet)
- **Gateway:** 192.168.137.1 (Windows PC)
- **Internet:** Via Windows PC ICS (requires PC to be on)

### Primary Function: Git Backup Mirror
- **Location:** `~/git-mirrors/*.git`
- **Repos:** 15 bare repositories
- **Schedule:** Every 4 hours (cron)
- **Log:** `~/git-mirrors/sync.log`

### Quick Commands

```bash
# Manual sync
~/git-mirrors/sync-mirrors.sh

# Check sync log
tail -20 ~/git-mirrors/sync.log

# List mirrored repos
ls ~/git-mirrors/*.git

# Check disk usage
df -h

# Test internet (requires PC on)
ping -c 3 github.com
```

---

## Workflow Summary

1. **Need info?** - Fetch from GitHub (see URLs above)
2. **Made changes?** - Save notes to `~/notes/YYYY-MM-DD-topic.md`
3. **Mac Claude** will SSH here later to retrieve and integrate your notes

The user will prompt Mac Claude with something like: "pull in the pi1 notes" and Mac Claude will SSH to this machine, read ~/notes/, and update the homelab docs.
